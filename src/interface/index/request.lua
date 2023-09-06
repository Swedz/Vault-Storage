local screen = {}

local inputBoxWidth = termWidth * 0.75
local inputBoxStartX = (termWidth / 2) - (inputBoxWidth / 2) + 2
local inputBoxStartY = (termHeight / 2)
local requestingItem
local input = ""

local windows = {}

windows.main = window.create(term.current(), 1, 1, termWidth, termHeight, false)
windows.main.setBackgroundColor(config.colors.requestItems.background)
windows.main.setTextColor(config.colors.requestItems.text)

windows.inputBox = window.create(windows.main, inputBoxStartX, inputBoxStartY + 2, inputBoxWidth, 1)
windows.inputBox.setBackgroundColor(config.colors.requestItemsAmount.background)
windows.inputBox.setTextColor(config.colors.requestItemsAmount.text)
windows.inputBox.setCursorBlink(true)

function screen:open(args)
    requestingItem = args
    windows.main.setVisible(true)
end

function screen:close()
    windows.main.setVisible(false)
end

function screen:draw()
    windows.main.clear()
    windows.main.setCursorPos(inputBoxStartX, inputBoxStartY)
    windows.main.setTextColor(config.colors.requestItems.text) -- why do I need to call this here for the text color to be set correctly???
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

--[[requestAmountBoxWidth = nil
requestAmountBoxStartX = nil
requestAmountBoxStartY = nil
function updateRequestTermSize()
    requestAmountBoxWidth = termWidth * 0.75
    requestAmountBoxStartX = (termWidth / 2) - (requestAmountBoxWidth / 2) + 2
    requestAmountBoxStartY = (termHeight / 2)

    -- We have this here so that if this is called after initial setup it will update the box position as well
    if windowRequestAmount ~= nil then
        windowRequestAmount.reposition(requestAmountBoxStartX, requestAmountBoxStartY + 2)
    end
end
updateRequestTermSize()

requestingItem = nil
requestBox = ""

windowRequest = window.create(term.current(), 1, 1, termWidth, termHeight, false)
windowRequest.setBackgroundColor(config.colors.requestItems.background)
windowRequest.setTextColor(config.colors.requestItems.text)

windowRequestAmount = window.create(windowRequest, requestAmountBoxStartX, requestAmountBoxStartY + 2, requestAmountBoxWidth, 1)
windowRequestAmount.setBackgroundColor(config.colors.requestItemsAmount.background)
windowRequestAmount.setTextColor(config.colors.requestItemsAmount.text)
windowRequestAmount.setCursorBlink(true)

function drawRequestScreen()
    windowRequest.clear()
    windowRequest.setCursorPos(requestAmountBoxStartX, requestAmountBoxStartY)
    windowRequest.setTextColor(config.colors.requestItems.text) -- why do I need to call this here for the text color to be set correctly???
    windowRequest.write("How much to request?")

    windowRequestAmount.clear()
    windowRequestAmount.setCursorPos(1, 1)
    windowRequestAmount.write(requestBox)
    windowRequestAmount.setCursorBlink(true)
end

function handleRequestScreen()
    drawRequestScreen()

    function handleTyping(char)
        if tonumber(char) then
            requestBox = requestBox .. char
        end
    end

    function handleKeyPressBackspace()
        if #requestBox > 0 then
            requestBox = string.sub(requestBox, 1, #requestBox - 1)
        end
    end

    function handleKeyPressEnter()
        local amountToRequest = tonumber(requestBox)
        if amountToRequest ~= nil and amountToRequest > 0 then
            depositorTurtleHalt = true
            cache:requestItems(computerName, cache.items[requestingItem], amountToRequest)
            depositorTurtleProtectSlots()
            depositorTurtleHalt = false
        end
        requestingItem = nil
        requestBox = ""
        setScreen("index")
    end

    function handleKeyPressDelete()
        requestingItem = nil
        requestBox = ""
        setScreen("index")
    end

    function handleKeyPress(key)
        if key == keys.backspace then
            handleKeyPressBackspace()
        elseif key == keys.enter or key == keys.numPadEnter then
            handleKeyPressEnter()
        elseif key == keys.delete then
            handleKeyPressDelete()
        end
    end

    depositorStart()

    while screen == "request" do
        local function tickMain()
            while screen == "request" do
                local eventData = { os.pullEvent() }
                local event = eventData[1]
                if event == "vault.screen_changed" and eventData[2] ~= "request" then
                    break
                elseif event == "char" then
                    handleTyping(eventData[2])
                elseif event == "key" then
                    handleKeyPress(eventData[2])
                elseif event == "term_resize" then
                    updateTermSize()
                    updateRequestTermSize()
                end
                if screen == "request" then
                    drawRequestScreen()
                end
            end
        end

        local function tickItemInserter()
            depositorRun(function() return screen == "request" end)
        end

        parallel.waitForAll(tickMain, tickItemInserter)
    end
end]]