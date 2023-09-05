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
    inventories = {},
    items = {}
}

function Cache:fullSetup()
    self:locateInventoryPeripherals()
    self:readAll(self.inventories)
    return self
end

function Cache:locateInventoryPeripherals()
    local peripherals = {}
    if config.inventory_peripheral ~= nil then
        peripherals = { peripheral.find(config.inventory_peripheral) }
    end
    for _, inventory in pairs(config.additional_inventory_peripherals) do
        for _, p in ipairs(findPeripheralsPattern(inventory)) do
            table.insert(peripherals, p)
        end
    end
    local inventories = {}
    for _, inventory in pairs(peripherals) do
        inventories[peripheral.getName(inventory)] = inventory
    end
    self.inventories = inventories
end

function Cache:insertItem(inventory, itemStack, slot, count)
    if count == nil then count = itemStack.count end

    local itemHash = hashItem(itemStack)
    local item = self.items[itemHash]
    if item == nil then
        if slot <= 0 then
            error("Tried to insert new and fresh item with evaluated invalid slot of " .. slot)
        end
        item = {
            hash = itemHash,
            count = count,
            detail = inventory.getItemDetail(slot),
            sources = {
                [peripheral.getName(inventory)] = { [slot] = true }
            }
        }
        self.items[itemHash] = item
    else
        item.count = item.count + count

        if slot > 0 then
            local sources = item.sources[peripheral.getName(inventory)]
            if sources == nil then sources = {} end
            sources[slot] = true
            item.sources[peripheral.getName(inventory)] = sources
        end
    end
end

function Cache:readAll(inventories)
    for _, inventory in pairs(inventories) do
        for slot, itemStack in pairs(inventory.list()) do
            self:insertItem(inventory, itemStack, slot, itemStack.count)
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
        if filter == nil or filter == "" or string.find(string.lower(item.detail.displayName), filter) and item ~= nil then
            result[index] = item
            index = index + 1
        end
    end
    if sort then
        table.sort(result, function(a, b)
            if a.count == b.count then
                return a.detail.displayName >= b.detail.displayName
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
            local itemDetail = inventory.getItemDetail(slot)
            local amountPushed = inventory.pushItems(targetInventory, slot, amount)

            -- Adjust our counts
            amount = amount - amountPushed
            item.count = item.count - amountPushed

            -- Mark this slot for removal
            if itemDetail.count <= amountPushed then
                table.insert(forgetSlots, slot)
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
    local itemStack = turtle.getItemDetail(slot)
    for _, inventory in pairs(self.inventories) do
        local emptySlots = {}
        for s = 1, inventory.size() do emptySlots[s] = true end
        for s, _ in pairs(inventory.list()) do emptySlots[s] = false end

        local amountInserted = inventory.pullItems(fromInventory, slot)
        if amountInserted > 0 then
            local filledSlot = -1
            for s, _ in pairs(inventory.list()) do if emptySlots[s] then filledSlot = s break end end
            self:insertItem(inventory, itemStack, filledSlot, amountInserted)
        end
    end
end

return Cache