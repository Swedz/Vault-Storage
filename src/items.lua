require("core")

function hashItem(item)
    if item == nil then return nil end
    local hash = item.name
    if not hash then error("Item has no hash") end
    if item.nbt then hash = hash .. "@" .. item.nbt end
    return hash
end

function unhashItem(hash)
    local name, nbt = hash:match("^([^@]+)@(.*)$")
    if name then return name, nbt else return hash, name end
end

Cache = {
    stats = {
        inventory_count = 0,
        slots_occupied = 0,
        slots_total = 0,
        items_current = 0,
        items_max = 0
    },
    inventories = {},
    containers = {},
    items = {}
}

function Cache:fullSetup()
    local start = os.epoch("utc")
    self:locateInventoryPeripherals()
    print("")
    print(("* Located inventory peripherals in %dms."):format(os.epoch("utc") - start))

    start = os.epoch("utc")
    self:readAll()
    print("")
    print(("* Read all items in %dms."):format(os.epoch("utc") - start))

    return self
end

function Cache:locateInventoryPeripherals()
    local peripherals = {}
    if config.inventory_peripheral ~= nil then
        peripherals = { peripheral.find(config.inventory_peripheral, function(peripheralName) return not depositorItemInserterIsInserter(peripheralName) end) }
    end
    for _, inventory in pairs(findInventoryPeripheralsPatterns(config.additional_inventory_peripherals)) do
        if not depositorItemInserterIsInserter(peripheral.getName(inventory)) then
            table.insert(peripherals, inventory)
        end
    end

    local inventories = {}
    local containers = {}
    for _, inventory in pairs(peripherals) do
        local inventoryName = peripheral.getName(inventory)
        self.stats.inventory_count = self.stats.inventory_count + 1
        self.stats.slots_total = self.stats.slots_total + inventory.size()

        inventories[inventoryName] = inventory

        local container = {}
        for slot, itemStack in pairs(inventory.list()) do
            container[slot] = itemStack
            self.stats.slots_occupied = self.stats.slots_occupied + 1
            self.stats.items_current = self.stats.items_current + itemStack.count
        end
        self.stats.items_max = self.stats.items_max + (inventory.getItemLimit(1) * inventory.size())
        containers[inventoryName] = container
    end
    self.inventories = inventories
    self.containers = containers
end

function Cache:insertItem(inventory, itemStack, slot, count)
    if count == nil then count = itemStack.count end

    local inventoryName = peripheral.getName(inventory)

    local itemHash = hashItem(itemStack)
    local item = self.items[itemHash]
    if item == nil then
        if slot <= 0 then
            error("Tried to insert new and fresh item with evaluated invalid slot of " .. slot)
        end
        self.items[itemHash] = {
            hash = itemHash,
            count = count,
            displayName = inventory.getItemDetail(slot).displayName,
            sources = {
                [inventoryName] = { [slot] = true }
            }
        }
    else
        item.count = item.count + count
        if slot > 0 then
            local sources = item.sources[inventoryName]
            if sources == nil then sources = {} end
            sources[slot] = true
            item.sources[inventoryName] = sources
        end
    end
end

function Cache:readAll()
    for containerName, container in pairs(self.containers) do
        for slot, itemStack in pairs(container) do
            self:insertItem(self.inventories[containerName], itemStack, slot, itemStack.count)
        end
    end
end

function Cache:dump(printSources)
    for hash, item in pairs(cache:getItems()) do
        local itemName, itemNBT = unhashItem(hash)
        if itemNBT == nil then
            print(item.count .. "x " .. itemName)
        else
            print(item.count .. "x " .. itemName .. " @ " .. itemNBT)
        end
        if printSources then
            local count = 0
            for _ in pairs(sources) do count = count + 1 end
            print(" sources (" .. count .. "): " .. textutils.serialize(item.sources, { compact = true }))
        end
    end
end

function Cache:getItems(sort, filter)
    if sort == nil then sort = true end
    if filter ~= nil and filter ~= "" then filter = string.lower(filter) end

    local result = {}
    local index = 1
    for _, item in pairs(self.items) do
        if filter == nil or filter == "" or string.find(string.lower(item.displayName), filter) and item ~= nil then
            result[index] = item
            index = index + 1
        end
    end
    if sort then
        table.sort(result, function(a, b)
            if a.count == b.count then
                return a.displayName >= b.displayName
            else
                return a.count >= b.count
            end
        end)
    end
    return result
end

function Cache:requestItems(targetInventory, item, amount)
    local forgetSources = {}
    for sourceName, slots in pairs(item.sources) do
        local forgetSlots = {}
        local inventory = self.inventories[sourceName]

        for slot, _ in pairs(slots) do
            -- Push the item from the inventory into the target inventory
            local amountPushed = -1
            while amountPushed ~= 0 do
                local itemDetail = self.containers[sourceName][slot]
                amountPushed = inventory.pushItems(targetInventory, slot, amount)
                if amountPushed == 0 then
                    break
                end

                -- Adjust our counts
                amount = amount - amountPushed
                item.count = item.count - amountPushed
                self.containers[sourceName][slot].count = itemDetail.count - amountPushed
                self.stats.items_current = self.stats.items_current - amountPushed

                -- Mark this slot for removal
                if itemDetail.count <= amountPushed then
                    self.containers[sourceName][slot] = nil
                    self.stats.slots_occupied = self.stats.slots_occupied - 1
                    table.insert(forgetSlots, slot)
                    break
                end

                -- If we don't need to request any more items, let's stop looking
                if amount <= 0 then
                    break
                end
            end
            -- If we don't need to request any more items, let's stop looking
            if amount <= 0 then
                break
            end
        end

        -- Forget the slots for this source
        for _, slot in pairs(forgetSlots) do
            slots[slot] = nil
            item.sources[sourceName][slot] = nil
        end
        -- Mark the source for removal if it has no more slots
        local slotCount = 0
        for _, v in pairs(slots) do if v ~= nil then slotCount = slotCount + 1 end end
        if slotCount == 0 then
            table.insert(forgetSources, sourceName)
        end

        -- If we don't need to request any more items, let's stop looking
        if amount <= 0 then
            break
        end
    end

    -- Forget the sources for this item
    for _, sourceName in pairs(forgetSources) do
        item.sources[sourceName] = nil
    end
    -- Forget the item if it has no sources anymore
    local sourceCount = 0
    for _, v in pairs(item.sources) do if v ~= nil then sourceCount = sourceCount + 1 end end
    if sourceCount == 0 then
        self.items[item.hash] = nil
    end
end

function Cache:depositItems(fromInventory, slot)
    local itemStack
    if fromInventory == computerName then
        itemStack = turtle.getItemDetail(slot)
    else
        itemStack = peripheral.wrap(fromInventory).getItemDetail(slot)
    end

    for _, inventory in pairs(self.inventories) do
        local emptySlots = {}
        for s = 1, inventory.size() do emptySlots[s] = true end
        for s, _ in pairs(self.containers[peripheral.getName(inventory)]) do emptySlots[s] = false end

        local amountInserted = inventory.pullItems(fromInventory, slot)
        if amountInserted > 0 then
            local filledSlot = -1
            for s, i in pairs(inventory.list()) do
                self.containers[peripheral.getName(inventory)][s] = i
                if emptySlots[s] and filledSlot == -1 then
                    filledSlot = s
                    self.stats.slots_occupied = self.stats.slots_occupied + 1
                end
            end
            self.stats.items_current = self.stats.items_current + amountInserted
            self:insertItem(inventory, itemStack, filledSlot, amountInserted)
        end
    end
end

return Cache