local screen = {}

local totalLines = 0
local linesDisplayed = termHeight - 2
local scroll = 0

local windows = {}
screen.windows = windows

windows.main = window.create(term.current(), 1, 1, termWidth, termHeight, false)

windows.tabs, windows.tabIndex, windows.tabDetails, windows.tabManual = interfaceutils.tabWindows(windows.main, "manual")

windows.split = window.create(windows.main, 1, 2, termWidth, 1)
windows.split.setBackgroundColor(config.colors.manual.split.background)
windows.split.setTextColor(config.colors.manual.split.text)

windows.body = window.create(windows.main, 1, 3, termWidth, termHeight - 2)
windows.body.setBackgroundColor(config.colors.manual.body.background)
windows.body.setTextColor(config.colors.manual.body.text.plain)

function screen:open(_)
    scroll = 0
end

function screen:close()
end

function screen:draw()
    windows.split.clear()
    windows.split.setCursorPos(1, 1)
    windows.split.write("Running Vault v" .. config.version)
    if config.debug then
        windows.split.setTextColor(colors.lightBlue)
        windows.split.write(" (DEBUG MODE)")
        windows.split.setTextColor(config.colors.manual.split.text)
    end

    windows.body.clear()

    totalLines = 1

    local function stepLine(lines)
        if lines == nil then lines = 1 end
        totalLines = totalLines + lines
    end

    local function writeControl(buttons, delimiter, label)
        windows.body.setCursorPos(1, totalLines - scroll)

        windows.body.setTextColor(config.colors.manual.body.text.highlighted)
        local buttonText = ""
        for _, button in pairs(buttons) do
            buttonText = buttonText .. "[" .. button .. "] "
        end
        windows.body.write(buttonText)

        windows.body.setTextColor(config.colors.manual.body.text.faded)
        windows.body.write(delimiter)
        windows.body.setTextColor(config.colors.manual.body.text.plain)
        windows.body.write(" " .. label)

        stepLine()
    end

    local function writeTextSection(label, text)
        windows.body.setCursorPos(1, totalLines - scroll)
        windows.body.setTextColor(config.colors.manual.body.text.highlighted)
        windows.body.write("\16 " .. label)

        stepLine()

        windows.body.setTextColor(config.colors.manual.body.text.plain)
        local wrappedLines = interfaceutils.writeWrap(windows.body, totalLines - scroll, text)

        stepLine(wrappedLines)
    end

    stepLine()
    writeControl({ "\27", "\26" }, " \140", "Swap tabs")
    writeControl({ "\25", "\24" }, " \156", "Shift selection or view")
    writeControl({ "SCROLL" }, "\133", "")
    writeControl({ "ENTER" }, " \140", "Select")
    writeControl({ "DELETE" }, "\140", "Cancel | Clear")
    writeControl({ "F1" }, "    \140", "Edit config")
    stepLine()
    writeTextSection("Inserting & Requesting Items", "Requested items are sent into the grid on the bottom right of the interface. Any items you insert into this grid will get sent into the system.")
    stepLine()
    writeTextSection("Configuring", "In order to edit the config for your Vault, you can press F1 while on this screen, or you can terminate the program and run \"edit vault/config\" and reboot the computer after saving your changes.")
end

local function handleScrollSelection(up)
    if up then
        if scroll > 0 then
            scroll = scroll - 1
            windows.body.scroll(-1)
        end
    else
        if scroll < totalLines - linesDisplayed - 1 then
            scroll = scroll + 1
            windows.body.scroll(1)
        end
    end
end

local function handleSwapTabs(left)
    if left then
        interfaces:setScreen("details")
    end
end

local function handleEditConfig()
    shell.execute("edit", "vault/config")
    os.reboot()
end

local function handleKeyPress(key)
    if key == keys.up or key == keys.down then
        handleScrollSelection(key == keys.up)
    elseif key == keys.left or key == keys.right then
        handleSwapTabs(key == keys.left)
    elseif key == keys.f1 then
        handleEditConfig()
    end
end

local function handleMouseScroll(direction)
    handleScrollSelection(direction == -1)
end

function screen:event(event, eventData)
    if event == "key" then
        handleKeyPress(eventData[2])
    elseif event == "mouse_scroll" then
        handleMouseScroll(eventData[2])
    end
end

return screen