depositorTimer = nil
depositorItemInserters = nil
depositorTurtleProtectedSlots = {}
depositorTurtleHalt = false

function depositorSetup()
    depositorTurtleProtectSlots()
    depositorItemInserterSetup()
end

function depositorStart()
    if depositorTimer ~= nil then
        os.cancelTimer(depositorTimer)
    end
    depositorTimer = os.startTimer(config.depositors.frequency)
end

function depositorRun(condition)
    while condition() do
        local _, timer = os.pullEvent("timer")
        if timer == depositorTimer then
            depositorHandle()
            depositorTimer = os.startTimer(config.depositors.frequency)
        end
    end
end

function depositorHandle()
    local queue = {}
    if depositorItemInserters ~= nil then
        depositorItemInserterHandle(queue)
    end
    if not depositorTurtleHalt then
        depositorTurtleHandle(queue)
    end
    processQueue(queue)
end

function depositorTurtleProtectSlots()
    for slot = 1, 16 do
        if turtle.getItemDetail(slot) then
            depositorTurtleProtectedSlots[slot] = true
        else
            depositorTurtleProtectedSlots[slot] = false
        end
    end
end

function depositorTurtleHandle(queue)
    for slot, protected in pairs(depositorTurtleProtectedSlots) do
        local item = turtle.getItemDetail(slot)
        if protected and not item then
            depositorTurtleProtectedSlots[slot] = false
        elseif not protected and item then
            table.insert(queue, function()
                cache:depositItems(computerName, slot)
                drawScreen()
            end)
        end
    end
end

function depositorItemInserterIsInserter(peripheralName)
    for _, pattern in pairs(config.depositors.inserters) do
        if peripheralName:match(pattern) then
            return true
        end
    end
    return false
end

function depositorItemInserterSetup()
    local inserters = findInventoryPeripheralsPatterns(config.depositors.inserters)
    if #inserters > 0 then
        depositorItemInserters = {}
        for _, itemInserter in pairs(inserters) do
            depositorItemInserters[peripheral.getName(itemInserter)] = itemInserter
        end
    end
end

function depositorItemInserterHandle(queue)
    for peripheralName, itemInserter in pairs(depositorItemInserters) do
        for slot, _ in pairs(itemInserter.list()) do
            table.insert(queue, function()
                cache:depositItems(peripheralName, slot)
                drawScreen()
            end)
        end
    end
end