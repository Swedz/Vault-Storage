local screen = {}

local windows = {}
screen.windows = windows

windows.main = window.create(term.current(), 1, 1, termWidth, termHeight, false)

windows.tabs, windows.tabIndex, windows.tabDetails, windows.tabManual = interfaceutils.tabWindows(windows.main, "manual")

windows.body = window.create(windows.main, 1, 2, termWidth, termHeight - 1)
windows.body.setBackgroundColor(config.colors.manual.body.background)
windows.body.setTextColor(config.colors.manual.body.text)

windows.split = window.create(windows.body, 1, 1, termWidth, 1)
windows.split.setBackgroundColor(config.colors.manual.split.background)

function screen:open(_)
end

function screen:close()
end

function screen:draw()
    windows.body.clear()
    windows.split.clear()

    -- TODO
end

local function handleSwapTabs(left)
    if left then
        interfaces:setScreen("details")
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