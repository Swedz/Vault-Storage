term.clear()
term.setCursorPos(1, 1)
print("Indexing inventories...")

require("vault_core")
computerName = peripheral.find("modem").getNameLocal()
cache = require("vault_items"):fullSetup()

protected_slots = {}
function turtleProtectSlots()
    for slot = 1, 16 do
        if turtle.getItemDetail(slot) then
            protected_slots[slot] = true
        else
            protected_slots[slot] = false
        end
    end
end
turtleProtectSlots()

termWidth, termHeight = term.getSize()
searchBox = ""

windowSearch = window.create(term.current(), 1, 1, termWidth, 1)
windowSearch.setBackgroundColor(config.colors.searchBox.background)
windowSearch.setTextColor(config.colors.searchBox.text)
windowSearch.clear()
windowSearch.setCursorPos(1, 1)
windowSearch.setCursorBlink(true)

windowIndexLabel = window.create(term.current(), 1, 2, termWidth, 1)
windowIndexLabel.setBackgroundColor(config.colors.indexHeader.background)
windowIndexLabel.setTextColor(config.colors.indexHeader.text)

windowIndexTop = window.create(term.current(), 1, 3, termWidth, 1)
windowIndexTop.setBackgroundColor(config.colors.indexHighlightedEntry.background)
windowIndexTop.setTextColor(config.colors.indexHighlightedEntry.text)

windowIndexBottom = window.create(term.current(), 1, 4, termWidth, termHeight - 3)
windowIndexBottom.setBackgroundColor(config.colors.indexContent.background)
windowIndexBottom.setTextColor(config.colors.indexContent.text)

function drawIndexScreen()
    local columnWidths = { termWidth * 0.75 - 1, termWidth * 0.25 - 1 }

    windowIndexLabel.clear()
    windowIndexLabel.setCursorPos(1, 1)
    writeTableLine(windowIndexLabel, { "Item", "Count" }, columnWidths)
    windowIndexTop.clear()
    windowIndexBottom.clear()

    local matchingItems = cache:getItems(true, searchBox)

    if #matchingItems == 0 then
        windowIndexTop.setBackgroundColor(config.colors.indexContent.background)
    else
        windowIndexTop.setBackgroundColor(config.colors.indexHighlightedEntry.background)
    end

    local line = 1
    for _, item in ipairs(matchingItems) do
        local localLine = line
        local window = windowIndexTop
        if line > 1 then
            localLine = line - 1
            window = windowIndexBottom
        end

        window.setCursorPos(1, localLine)
        writeTableLine(window, { item.detail.displayName, formatCount(item.count) }, columnWidths)

        line = line + 1
    end

    -- Used for writing debug information on the bottom of the screen
    --windowIndexBottom.setCursorPos(1, termHeight - 4)
    --windowIndexBottom.write(("%d & %s"):format(#matchingItems, #matchingItems > 0))

    windowSearch.setCursorPos(1, 1)
    windowSearch.clearLine()
    windowSearch.write(searchBox)
    windowSearch.setCursorBlink(true)
end

drawIndexScreen()

function handleTyping(char)
    searchBox = searchBox .. char
end

function handleKeyPressBackspace()
    if #searchBox > 0 then
        searchBox = string.sub(searchBox, 1, #searchBox - 1)
    end
end

function handleKeyPressEnter()
    local matchingItems = cache:getItems(true, searchBox)
    local selectedItem = matchingItems[next(matchingItems)]
    if selectedItem ~= nil then
        cache:requestItems(computerName, selectedItem, 4)
        turtleProtectSlots()
    end
end

function handleKeyPressLeftCtrl()
    local matchingItems = cache:getItems(true, searchBox)
    local selectedItem = matchingItems[next(matchingItems)]
    if selectedItem ~= nil then
        debug(textutils.serialize(selectedItem))
    end
end

function handleKeyPress(key)
    if key == keys.backspace then
        handleKeyPressBackspace()
    elseif key == keys.enter then
        handleKeyPressEnter()
    elseif key == keys.leftCtrl and config.debug then
        handleKeyPressLeftCtrl()
    end
end

function handleTurtleInventory()
    for slot, protected in pairs(protected_slots) do
        local item = turtle.getItemDetail(slot)
        if protected and not item then
            protected_slots[slot] = false
        elseif not protected and item then
            cache:depositItems(computerName, slot)
            sleep(0.05)
        end
    end
end

while true do
    local eventData = { os.pullEvent() }
    local event = eventData[1]
    if event == "char" then
        handleTyping(eventData[2])
    elseif event == "key" then
        handleKeyPress(eventData[2])
    elseif event == "turtle_inventory" then
        handleTurtleInventory()
    end
    drawIndexScreen()
end