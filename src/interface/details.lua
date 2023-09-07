local screen = {}

local windows = {}
screen.windows = windows

windows.main = window.create(term.current(), 1, 1, termWidth, termHeight, false)

windows.tabs, windows.tabIndex, windows.tabDetails, windows.tabManual = interfaceutils.tabWindows(windows.main, "details")

windows.split = window.create(windows.main, 1, 2, termWidth, 1)
windows.split.setBackgroundColor(config.colors.details.split.background)
windows.split.setTextColor(config.colors.details.split.text)

windows.body = window.create(windows.main, 1, 3, termWidth, termHeight - 1)
windows.body.setBackgroundColor(config.colors.details.body.background)
windows.body.setTextColor(config.colors.details.body.text.plain)

function screen:open(_)
end

function screen:close()
end

function screen:draw()
    windows.split.clear()

    windows.body.clear()

    local function drawPartialBar(line, label, extra, fraction)
        local color
        if fraction < 0.25 then
            color = config.colors.details.body.text.fractional.low
        elseif fraction < 0.5 then
            color = config.colors.details.body.text.fractional.medium
        elseif fraction < 0.75 then
            color = config.colors.details.body.text.fractional.high
        else
            color = config.colors.details.body.text.fractional.full
        end
        windows.body.setTextColor(color)

        windows.body.setCursorPos(1, line)
        windows.body.write(label)

        if extra ~= nil then
            windows.body.setCursorPos(termWidth - #extra + 1, line)
            windows.body.write(extra)
        end

        windows.body.setCursorPos(1, line + 1)
        local filled = math.ceil(fraction * termWidth)
        windows.body.write(string.rep("\143", filled))
        local empty = math.floor(termWidth - filled)
        windows.body.setTextColor(colors.black)
        windows.body.write(string.rep("\143", empty))
    end
    local function drawPartialBarShorthand(line, label, part, total)
        local fraction = part / total
        drawPartialBar(line, label, ("%s / %s [%.2f%%]"):format(formatCount(part), formatCount(total), fraction * 100), fraction)
    end

    drawPartialBarShorthand(2, "Items", cache.stats.items_current, cache.stats.items_max)
    drawPartialBarShorthand(5, "Slots", cache.stats.slots_occupied, cache.stats.slots_total)

    windows.body.setCursorPos(1, 8)
    windows.body.setTextColor(config.colors.details.body.text.highlighted)
    windows.body.write("Attached Inventories")
    windows.body.setTextColor(config.colors.details.body.text.faded)
    windows.body.write(" \183 ")
    windows.body.setTextColor(config.colors.details.body.text.plain)
    windows.body.write(formatCount(cache.stats.inventory_count))

end

local function handleSwapTabs(left)
    if left then
        interfaces:setScreen("index")
    else
        interfaces:setScreen("manual")
    end
end

local function handleKeyPress(key)
    if key == keys.left or key == keys.right then
        handleSwapTabs(key == keys.left)
    end
end

function screen:event(event, eventData)
    if event == "key" then
        handleKeyPress(eventData[2])
    end
end

return screen