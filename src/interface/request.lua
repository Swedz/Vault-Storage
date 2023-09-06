requestAmountBoxWidth = nil
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

    function handleKeyPressEscape()
        requestingItem = nil
        requestBox = ""
        setScreen("index")
    end

    function handleKeyPress(key)
        if key == keys.backspace then
            handleKeyPressBackspace()
        elseif key == keys.enter then
            handleKeyPressEnter()
        elseif key == keys.escape then
            handleKeyPressEscape()
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
                elseif event == "turtle_inventory" then
                    handleTurtleInventory()
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
end