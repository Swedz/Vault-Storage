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