local interfaceutils = {}

function interfaceutils.writeTableLine(window, columnTexts, columnWidths)
    local _, cy = window.getCursorPos()
    local x = 1
    for index, text in pairs(columnTexts) do
        local width = columnWidths[index]

        window.setCursorPos(x, cy)
        window.write(string.sub(text, 1, width))

        if index < #columnTexts then
            window.setCursorPos(x + width + 1, cy)
            window.write("\149")
        end

        x = x + width + 3
    end
end

function interfaceutils.tabWindows(windowParent, selected)
    local tabCount = 3
    local tabWidth = termWidth / tabCount

    local tabs = window.create(windowParent, 1, 1, termWidth, 1)

    local function createTab(index, id, label)
        local tab = window.create(tabs, ((index - 1) * tabWidth) + 1, 1, tabWidth, 1)
        if selected == id then
            tab.setBackgroundColor(config.colors.tabs.selected.background)
            tab.setTextColor(config.colors.tabs.selected.text)
        else
            tab.setBackgroundColor(config.colors.tabs.deselected.background)
            tab.setTextColor(config.colors.tabs.deselected.text)
        end
        tab.clearLine()
        local labelXPadding = 1
        if index == 3 then
            labelXPadding = 2
        end
        tab.setCursorPos(tabWidth / 2 - #label / 2 + labelXPadding, 1)
        tab.write(label)
        return tab
    end

    return tabs, createTab(1, "index", "Index"), createTab(2, "details", "Details"), createTab(3, "manual", "Manual")
end

function interfaceutils.writeWrap(window, line, text)
    local windowWidth, _ = window.getSize()

    local lines = {}
    local currentLineText
    for word in string.gmatch(text, "[^%s]+") do
        local currentLineTextLocal = currentLineText
        if currentLineTextLocal == nil then currentLineTextLocal = word else currentLineTextLocal = currentLineTextLocal .. " " .. word end
        if #currentLineTextLocal == windowWidth then
            table.insert(lines, currentLineTextLocal)
            currentLineText = nil
        elseif #currentLineTextLocal > windowWidth then
            table.insert(lines, currentLineText)
            currentLineText = word
        else
            currentLineText = currentLineTextLocal
        end
    end
    if currentLineText ~= nil then
        table.insert(lines, currentLineText)
    end

    for i, lineText in ipairs(lines) do
        window.setCursorPos(1, line + i - 1)
        window.write(lineText)
    end

    return #lines
end

return interfaceutils