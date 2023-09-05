itemInserters = nil
itemInserterTimer = nil

function isItemInserter(peripheralName)
    for _, pattern in pairs(config.item_inserters) do
        if peripheralName:match(pattern) then
            return true
        end
    end
    return false
end

function setupItemInserters()
    local inserters = findInventoryPeripheralsPatterns(config.item_inserters)
    if #inserters > 0 then
        itemInserters = {}
        for _, itemInserter in pairs(inserters) do
            itemInserters[peripheral.getName(itemInserter)] = itemInserter
        end
    end
end

function startItemInserter()
    if itemInserters ~= nil then
        if itemInserterTimer ~= nil then
            os.cancelTimer(itemInserterTimer)
        end
        itemInserterTimer = os.startTimer(1)
    end
end

function handleItemInserter()
    local queue = {}

    for peripheralName, itemInserter in pairs(itemInserters) do
        for slot, _ in pairs(itemInserter.list()) do
            table.insert(queue, function()
                cache:depositItems(peripheralName, slot)
                drawScreen()
            end)
        end
    end

    processQueue(queue)
end

function handleTickItemInserter(condition)
    while condition() and itemInserters ~= nil do
        local _, timer = os.pullEvent("timer")
        if timer == itemInserterTimer then
            handleItemInserter()
            itemInserterTimer = os.startTimer(1)
        end
    end
end