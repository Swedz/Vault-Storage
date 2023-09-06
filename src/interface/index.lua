searchBox = ""
highlightedLine = 1
indexOffset = 0

function getHighlightedItem()
    local matchingItems = cache:getItems(true, searchBox)
    local nextIndex
    if highlightedLine > 1 then nextIndex = highlightedLine - 1 + indexOffset end
    local selectedItem = matchingItems[next(matchingItems, nextIndex)]
    return selectedItem
end

windowIndex = window.create(term.current(), 1, 1, termWidth, termHeight, false)

windowIndexSearch = window.create(windowIndex, 1, 1, termWidth, 1)
windowIndexSearch.setBackgroundColor(config.colors.indexSearchBox.background)
windowIndexSearch.setTextColor(config.colors.indexSearchBox.text)
windowIndexSearch.clear()
windowIndexSearch.setCursorPos(1, 1)
windowIndexSearch.setCursorBlink(true)

windowIndexLabel = window.create(windowIndex, 1, 2, termWidth, 1)
windowIndexLabel.setBackgroundColor(config.colors.indexHeader.background)
windowIndexLabel.setTextColor(config.colors.indexHeader.text)

windowIndexContent = window.create(windowIndex, 1, 3, termWidth, termHeight - 3)
windowIndexContent.setBackgroundColor(config.colors.indexContent.background)
windowIndexContent.setTextColor(config.colors.indexContent.text)

windowIndexSelectedLine = window.create(windowIndexContent, 1, highlightedLine, termWidth, 1)
windowIndexSelectedLine.setBackgroundColor(config.colors.indexHighlightedEntry.background)
windowIndexSelectedLine.setTextColor(config.colors.indexHighlightedEntry.text)

windowIndexInfo = window.create(windowIndex, 1, termHeight, termWidth, 1)
windowIndexInfo.setBackgroundColor(config.colors.indexInfo.background)
windowIndexInfo.setTextColor(config.colors.indexInfo.text)

maxEntryLines = nil
totalEntries = nil
totalEntriesDisplayed = nil
function updateIndexTermSize()
    maxEntryLines = termHeight - 3
end
updateIndexTermSize()

function drawIndexScreen()
    local columnWidths = { termWidth * 0.75 - 1, termWidth * 0.25 - 1 }

    windowIndexInfo.clear()
    windowIndexInfo.setCursorPos(1, 1)
    windowIndexInfo.write(("Items: %s / %s (%.2f%%)"):format(formatCount(cache.stats.items_current), formatCount(cache.stats.items_max), cache.stats.items_current / cache.stats.items_max * 100))

    windowIndexLabel.clear()
    windowIndexLabel.setCursorPos(1, 1)
    writeTableLine(windowIndexLabel, { "Item", "Count" }, columnWidths)
    windowIndexSelectedLine.clear()
    windowIndexContent.clear()

    local matchingItems = cache:getItems(true, searchBox)

    if #matchingItems == 0 then
        windowIndexSelectedLine.setBackgroundColor(config.colors.indexContent.background)
    else
        windowIndexSelectedLine.setBackgroundColor(config.colors.indexHighlightedEntry.background)
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
        windowIndexSelectedLine.reposition(1, highlightedLine)
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
            local window = windowIndexContent
            if line == highlightedLine then
                localLine = 1
                window = windowIndexSelectedLine
            end

            window.setCursorPos(1, localLine)
            writeTableLine(window, { item.displayName, formatCount(item.count) }, columnWidths)
        end
    end

    windowIndexSearch.setCursorPos(1, 1)
    windowIndexSearch.clearLine()
    windowIndexSearch.write(searchBox)
    windowIndexSearch.setCursorBlink(true)
end

function handleIndexScreen()
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
            requestingItem = selectedItem.hash
            setScreen("request")
        end
    end

    function handleScrollSelection(up)
        if up then
            if highlightedLine > 1 then
                highlightedLine = highlightedLine - 1
                windowIndexSelectedLine.reposition(1, highlightedLine)
            elseif highlightedLine == 1 and indexOffset > 0 then
                indexOffset = indexOffset - 1
            end
        else
            if highlightedLine < totalEntriesDisplayed then
                highlightedLine = highlightedLine + 1
                windowIndexSelectedLine.reposition(1, highlightedLine)
            elseif highlightedLine == totalEntriesDisplayed and indexOffset < totalEntries - totalEntriesDisplayed then
                indexOffset = indexOffset + 1
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
            handleScrollSelection(key == keys.up)
        elseif key == keys.leftCtrl and config.debug then
            handleKeyPressLeftCtrl()
        end
    end

    function handleMouseScroll(direction)
        handleScrollSelection(direction == -1)
    end

    depositorStart()

    while screen == "index" do
        local function tickMain()
            while screen == "index" do
                local eventData = { os.pullEvent() }
                local event = eventData[1]
                if event == "vault.screen_changed" and eventData[2] ~= "index" then
                    break
                elseif event == "char" then
                    handleTyping(eventData[2])
                elseif event == "key" then
                    handleKeyPress(eventData[2])
                elseif event == "mouse_scroll" then
                    handleMouseScroll(eventData[2])
                elseif event == "term_resize" then
                    updateTermSize()
                    updateIndexTermSize()
                end
                if screen == "index" then
                    drawIndexScreen()
                end
            end
        end

        local function tickItemInserter()
            depositorRun(function() return screen == "index" end)
        end

        parallel.waitForAll(tickMain, tickItemInserter)
    end
end