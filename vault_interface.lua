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

termWidth, termHeight = nil
maxEntryLines = nil
totalEntriesDisplayed = nil
function updateTermSize()
    termWidth, termHeight = term.getSize()
    maxEntryLines = termHeight - 2
end
updateTermSize()

searchBox = ""
highlightedLine = 1

function getHighlightedItem()
    local matchingItems = cache:getItems(true, searchBox)
    local nextIndex
    if highlightedLine > 1 then nextIndex = highlightedLine - 1 end
    local selectedItem = matchingItems[next(matchingItems, nextIndex)]
    return selectedItem
end

windowSearch = window.create(term.current(), 1, 1, termWidth, 1)
windowSearch.setBackgroundColor(config.colors.searchBox.background)
windowSearch.setTextColor(config.colors.searchBox.text)
windowSearch.clear()
windowSearch.setCursorPos(1, 1)
windowSearch.setCursorBlink(true)

windowIndexLabel = window.create(term.current(), 1, 2, termWidth, 1)
windowIndexLabel.setBackgroundColor(config.colors.indexHeader.background)
windowIndexLabel.setTextColor(config.colors.indexHeader.text)

windowIndexBottom = window.create(term.current(), 1, 3, termWidth, termHeight - 2)
windowIndexBottom.setBackgroundColor(config.colors.indexContent.background)
windowIndexBottom.setTextColor(config.colors.indexContent.text)

windowIndexSelected = window.create(windowIndexBottom, 1, highlightedLine, termWidth, 1)
windowIndexSelected.setBackgroundColor(config.colors.indexHighlightedEntry.background)
windowIndexSelected.setTextColor(config.colors.indexHighlightedEntry.text)

function drawIndexScreen()
    local columnWidths = { termWidth * 0.75 - 1, termWidth * 0.25 - 1 }

    windowIndexLabel.clear()
    windowIndexLabel.setCursorPos(1, 1)
    writeTableLine(windowIndexLabel, { "Item", "Count" }, columnWidths)
    windowIndexSelected.clear()
    windowIndexBottom.clear()

    local matchingItems = cache:getItems(true, searchBox)

    if #matchingItems == 0 then
        windowIndexSelected.setBackgroundColor(config.colors.indexContent.background)
    else
        windowIndexSelected.setBackgroundColor(config.colors.indexHighlightedEntry.background)
    end

    local line = 0
    for _, item in ipairs(matchingItems) do
        line = line + 1
        if line > maxEntryLines then
            line = line - 1
            break
        end

        local localLine = line
        local window = windowIndexBottom
        if line == highlightedLine then
            localLine = 1
            window = windowIndexSelected
        end

        window.setCursorPos(1, localLine)
        writeTableLine(window, { item.detail.displayName, formatCount(item.count) }, columnWidths)
    end
    totalEntriesDisplayed = line

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
    local selectedItem = getHighlightedItem()
    if selectedItem ~= nil then
        cache:requestItems(computerName, selectedItem, 4)
        turtleProtectSlots()
    end
end

function handleKeyPressUpDownArrow(up)
    if up then
        if highlightedLine > 1 then
            highlightedLine = highlightedLine - 1
            windowIndexSelected.reposition(1, highlightedLine)
        end
    else
        if highlightedLine < totalEntriesDisplayed then
            highlightedLine = highlightedLine + 1
            windowIndexSelected.reposition(1, highlightedLine)
        end
    end
end

function handleKeyPressLeftCtrl()
    local selectedItem = getHighlightedItem()
    if selectedItem ~= nil then
        debug(textutils.serialize(selectedItem))
    end
end

function handleKeyPress(key)
    if key == keys.backspace then
        handleKeyPressBackspace()
    elseif key == keys.enter then
        handleKeyPressEnter()
    elseif key == keys.up or key == keys.down then
        handleKeyPressUpDownArrow(key == keys.up)
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
    elseif event == "term_resize" then
        updateTermSize()
    end
    drawIndexScreen()
end