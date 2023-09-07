local screen = {}

local maxEntryLines = termHeight - 3
local totalEntries, totalEntriesDisplayed
local searchBox = ""
local highlightedLine = 1
local indexOffset = 0

local windows = {}
screen.windows = windows

windows.main = window.create(term.current(), 1, 1, termWidth, termHeight, false)

windows.tabs, windows.tabIndex, windows.tabDetails, windows.tabManual = interfaceutils.tabWindows(windows.main, "index")

windows.search = window.create(windows.main, 1, 2, termWidth, 1)
windows.search.setBackgroundColor(config.colors.index.search.background)
windows.search.setTextColor(config.colors.index.search.text)
windows.search.clear()
windows.search.setCursorPos(1, 1)
windows.search.setCursorBlink(true)

windows.header = window.create(windows.main, 1, 3, termWidth, 1)
windows.header.setBackgroundColor(config.colors.index.header.background)
windows.header.setTextColor(config.colors.index.header.text)

windows.content = window.create(windows.main, 1, 4, termWidth, termHeight - 3)
windows.content.setBackgroundColor(config.colors.index.content.background)
windows.content.setTextColor(config.colors.index.content.text)

windows.highlightedEntry = window.create(windows.content, 1, highlightedLine, termWidth, 1)
windows.highlightedEntry.setBackgroundColor(config.colors.index.highlightedEntry.background)
windows.highlightedEntry.setTextColor(config.colors.index.highlightedEntry.text)

local function getHighlightedItem()
    local matchingItems = cache:getItems(true, searchBox)
    local nextIndex
    if highlightedLine > 1 then nextIndex = highlightedLine - 1 + indexOffset end
    return matchingItems[next(matchingItems, nextIndex)]
end

function screen:open(_)
end

function screen:close()
end

function screen:draw()
    local columnWidths = { termWidth * 0.75 - 1, termWidth * 0.25 - 1 }

    windows.header.clear()
    windows.header.setCursorPos(1, 1)
    interfaceutils.writeTableLine(windows.header, { "Item", "Count" }, columnWidths)
    windows.highlightedEntry.clear()
    windows.content.clear()

    local matchingItems = cache:getItems(true, searchBox)

    if #matchingItems == 0 then
        windows.highlightedEntry.setBackgroundColor(config.colors.index.content.background)
    else
        windows.highlightedEntry.setBackgroundColor(config.colors.index.highlightedEntry.background)
    end

    local entriesDisplayed = 0
    for _, _ in ipairs(matchingItems) do
        entriesDisplayed = entriesDisplayed + 1
        if entriesDisplayed > maxEntryLines then
            entriesDisplayed = entriesDisplayed - 1
            break
        end
    end
    totalEntries = #matchingItems
    totalEntriesDisplayed = entriesDisplayed
    if highlightedLine > totalEntriesDisplayed and totalEntriesDisplayed > 0 then
        highlightedLine = totalEntriesDisplayed
        windows.highlightedEntry.reposition(1, highlightedLine)
    end
    if indexOffset > totalEntries - totalEntriesDisplayed then
        indexOffset = totalEntries - totalEntriesDisplayed
    end

    local line = 0
    for index, item in ipairs(matchingItems) do
        if index > indexOffset then
            line = line + 1
            if line > maxEntryLines then
                break
            end

            local localLine = line
            local window = windows.content
            if line == highlightedLine then
                localLine = 1
                window = windows.highlightedEntry
            end

            window.setCursorPos(1, localLine)
            interfaceutils.writeTableLine(window, { item.displayName, formatCount(item.count) }, columnWidths)
        end
    end

    windows.search.setCursorPos(1, 1)
    windows.search.clearLine()
    windows.search.write(searchBox)
    windows.search.setCursorBlink(true)
end

local function handleTyping(char)
    searchBox = searchBox .. char
end

local function handleKeyPressBackspace()
    if #searchBox > 0 then
        searchBox = string.sub(searchBox, 1, #searchBox - 1)
    end
end

local function handleKeyPressEnter()
    local selectedItem = getHighlightedItem()
    if selectedItem ~= nil then
        interfaces:setScreen("index_request", selectedItem.hash)
    end
end

local function handleKeyPressDelete()
    searchBox = ""
end

local function handleScrollSelection(up)
    if up then
        if highlightedLine > 1 then
            highlightedLine = highlightedLine - 1
            windows.highlightedEntry.reposition(1, highlightedLine)
        elseif highlightedLine == 1 and indexOffset > 0 then
            indexOffset = indexOffset - 1
        end
    else
        if highlightedLine < totalEntriesDisplayed then
            highlightedLine = highlightedLine + 1
            windows.highlightedEntry.reposition(1, highlightedLine)
        elseif highlightedLine == totalEntriesDisplayed and indexOffset < totalEntries - totalEntriesDisplayed then
            indexOffset = indexOffset + 1
        end
    end
end

local function handleSwapTabs(left)
    if not left then
        interfaces:setScreen("details")
    end
end

local function handleKeyPressLeftCtrl()
    local selectedItem = getHighlightedItem()
    if selectedItem ~= nil then
        debug(textutils.serialize(selectedItem))
    end
end

local function handleKeyPress(key)
    if key == keys.backspace then
        handleKeyPressBackspace()
    elseif key == keys.enter or key == keys.numPadEnter then
        handleKeyPressEnter()
    elseif key == keys.delete then
        handleKeyPressDelete()
    elseif key == keys.up or key == keys.down then
        handleScrollSelection(key == keys.up)
    elseif key == keys.left or key == keys.right then
        handleSwapTabs(key == keys.left)
    elseif key == keys.leftCtrl and config.debug then
        handleKeyPressLeftCtrl()
    end
end

local function handleMouseScroll(direction)
    handleScrollSelection(direction == -1)
end

function screen:event(event, eventData)
    if event == "char" then
        handleTyping(eventData[2])
    elseif event == "key" then
        handleKeyPress(eventData[2])
    elseif event == "mouse_scroll" then
        handleMouseScroll(eventData[2])
    end
end

return screen