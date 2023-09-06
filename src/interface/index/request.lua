local screen = {}

local inputBoxWidth = termWidth * 0.75
local inputBoxStartX = (termWidth / 2) - (inputBoxWidth / 2) + 2
local inputBoxStartY = (termHeight / 2)
local requestingItem
local input = ""

local windows = {}
screen.windows = windows

windows.main = window.create(term.current(), 1, 1, termWidth, termHeight, false)
windows.main.setBackgroundColor(config.colors.index_request.body.background)
windows.main.setTextColor(config.colors.index_request.body.text)

windows.inputBox = window.create(windows.main, inputBoxStartX, inputBoxStartY + 2, inputBoxWidth, 1)
windows.inputBox.setBackgroundColor(config.colors.index_request.input.background)
windows.inputBox.setTextColor(config.colors.index_request.input.text)
windows.inputBox.setCursorBlink(true)

function screen:open(args)
    requestingItem = args
end

function screen:close()
end

function screen:draw()
    windows.main.clear()
    windows.main.setCursorPos(inputBoxStartX, inputBoxStartY)
    windows.main.setTextColor(config.colors.index_request.body.text) -- why do I need to call this here for the text color to be set correctly???
    windows.main.write("How much to request?")

    windows.inputBox.clear()
    windows.inputBox.setCursorPos(1, 1)
    windows.inputBox.write(input)
    windows.inputBox.setCursorBlink(true)
end

local function handleTyping(char)
    if tonumber(char) then
        input = input .. char
    end
end

local function handleKeyPressBackspace()
    if #input > 0 then
        input = string.sub(input, 1, #input - 1)
    end
end

local function handleKeyPressEnter()
    local amountToRequest = tonumber(input)
    if amountToRequest ~= nil and amountToRequest > 0 then
        depositor.turtle.halt = true
        cache:requestItems(computerName, cache.items[requestingItem], amountToRequest)
        depositor:turtleProtectSlots()
        depositor.turtle.halt = false
    end
    requestingItem = nil
    input = ""
    interfaces:setScreen("index")
end

local function handleKeyPressDelete()
    requestingItem = nil
    input = ""
    interfaces:setScreen("index")
end

local function handleKeyPress(key)
    if key == keys.backspace then
        handleKeyPressBackspace()
    elseif key == keys.enter or key == keys.numPadEnter then
        handleKeyPressEnter()
    elseif key == keys.delete then
        handleKeyPressDelete()
    end
end

function screen:event(event, eventData)
    if event == "char" then
        handleTyping(eventData[2])
    elseif event == "key" then
        handleKeyPress(eventData[2])
    end
end

return screen