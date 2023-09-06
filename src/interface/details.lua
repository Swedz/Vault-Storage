local screen = {}

local windows = {}
screen.windows = windows

windows.main = window.create(term.current(), 1, 1, termWidth, termHeight, false)

windows.tabs, windows.tabIndex, windows.tabDetails, windows.tabManual = interfaceutils.tabWindows(windows.main, "details")

windows.body = window.create(windows.main, 1, 2, termWidth, termHeight - 1)
windows.body.setBackgroundColor(config.colors.details.body.background)
windows.body.setTextColor(config.colors.details.body.text)

windows.split = window.create(windows.body, 1, 1, termWidth, 1)
windows.split.setBackgroundColor(config.colors.details.split.background)
windows.split.setTextColor(config.colors.details.split.text)

function screen:open(_)
end

function screen:close()
end

function screen:draw()
    windows.body.clear()

    windows.split.clear()
    windows.split.setCursorPos(1, 1)
    windows.split.write("Running Vault v" .. config.version)
    if config.debug then
        windows.split.setTextColor(colors.lightBlue)
        windows.split.write(" (DEBUG MODE)")
        windows.split.setTextColor(config.colors.details.split.text)
    end
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