local depositor = {
    timer = nil,
    itemInserters = nil,
    turtle = {
        protectedSlots = {},
        halt = false
    }
}

function depositor:setup()
    self:turtleProtectSlots()
    self:itemInserterSetup()
    return self
end

function depositor:start()
    if self.timer ~= nil then
        os.cancelTimer(self.timer)
    end
    self.timer = os.startTimer(config.depositors.frequency)
end

function depositor:run(condition)
    while condition() do
        local _, timer = os.pullEvent("timer")
        if timer == self.timer then
            local queue = {}
            if self.itemInserters ~= nil then
                self:itemInserterHandle(queue)
            end
            if not self.turtle.halt then
                self:turtleHandle(queue)
            end
            processQueue(queue)

            self.timer = os.startTimer(config.depositors.frequency)
        end
    end
end

function depositor:turtleProtectSlots()
    for slot = 1, 16 do
        if turtle.getItemDetail(slot) then
            self.turtle.protectedSlots[slot] = true
        else
            self.turtle.protectedSlots[slot] = false
        end
    end
end

function depositor:turtleHandle(queue)
    for slot, protected in pairs(self.turtle.protectedSlots) do
        local item
        if turtle.getItemCount(slot) > 0 then
            item = turtle.getItemDetail(slot, true)
        end
        if protected and not item then
            self.turtle.protectedSlots[slot] = false
        elseif not protected and item then
            cache:initItemFromStack(item)
            table.insert(queue, function()
                cache:depositItems(computerName, slot)
                interfaces:forceDrawScreen()
            end)
        end
    end
end

function depositor:isItemInserter(peripheralName)
    for _, pattern in pairs(config.depositors.inserters) do
        if peripheralName:match(pattern) then
            return true
        end
    end
    return false
end

function depositor:itemInserterSetup()
    local inserters = findInventoryPeripheralsPatterns(config.depositors.inserters)
    if #inserters > 0 then
        self.itemInserters = {}
        for _, itemInserter in pairs(inserters) do
            self.itemInserters[peripheral.getName(itemInserter)] = itemInserter
        end
    end
end

function depositor:itemInserterHandle(queue)
    for peripheralName, itemInserter in pairs(self.itemInserters) do
        for slot, itemStack in pairs(itemInserter.list()) do
            cache:initItemFromInventory(itemInserter, slot, itemStack)
            table.insert(queue, function()
                cache:depositItems(peripheralName, slot)
                interfaces:forceDrawScreen()
            end)
        end
    end
end

return depositor