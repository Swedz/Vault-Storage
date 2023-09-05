config = require("config")

function debug(message)
    local chatBox = peripheral.find("chatBox")
    if chatBox ~= nil and config.debug then
        chatBox.sendMessage(message)
    end
end

function writeTableLine(window, columnTexts, columnWidths)
    local _, cy = window.getCursorPos()
    local x = 1
    for index, text in pairs(columnTexts) do
        local width = columnWidths[index]

        window.setCursorPos(x, cy)
        window.write(string.sub(text, 1, width))

        if index < #columnTexts then
            window.setCursorPos(x + width + 1, cy)
            window.write("\149")
        end

        x = x + width + 3
    end
end

function formatCount(count)
    if count >= 10^9 then
        return ("%.2fB"):format(count / 10^9)
    elseif count >= 10^6 then
        return ("%.2fM"):format(count / 10^6)
    elseif count >= 10^3 then
        return ("%.2fK"):format(count / 10^3)
    else
        return tostring(count)
    end
end

function findInventoryPeripheralsPattern(pattern)
    return { peripheral.find("inventory", function(peripheralName)
        return peripheralName:match(pattern)
    end) }
end

function findInventoryPeripheralsPatterns(patterns)
    local peripherals = {}
    for _, pattern in pairs(patterns) do
        for _, p in ipairs(findInventoryPeripheralsPattern(pattern)) do
            table.insert(peripherals, p)
        end
    end
    return peripherals
end

partitionSize = 128
function processQueue(queue)
    local data_functions = {}

    local size = #queue
    local partitions = math.ceil(size / partitionSize)
    for i = 1, size do
        local current_part = math.ceil(i / partitionSize)
        local partition_location = (i - 1) % partitionSize + 1

        if not data_functions[current_part] then
            data_functions[current_part] = {}
        end

        data_functions[current_part][partition_location] = queue[i]
    end

    for i = 1, partitions do
        local partition = data_functions[i]
        parallel.waitForAll(table.unpack(partition,1,#partition))
    end
end