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

return interfaceutils