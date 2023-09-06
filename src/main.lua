local start = os.epoch("utc")

term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.green)
print("Indexing...")

termWidth, termHeight = nil
function updateTermSize()
    termWidth, termHeight = term.getSize()
end
updateTermSize()

require("core")
require("depositor")

depositorSetup()

screen = "index"
computerName = peripheral.find("modem").getNameLocal()
cache = require("items"):fullSetup()

term.setTextColor(colors.lime)
print("")
print(("Completed indexing process in %dms!"):format(os.epoch("utc") - start))
if config.debug then
    print("Press ENTER to continue.")
    repeat
        local _, key = os.pullEvent("key")
    until key == keys.enter
end
term.clear()

require("interface/index")
require("interface/request")

function drawScreen()
    if screen == "index" then
        drawIndexScreen()
    elseif screen == "request" then
        drawRequestScreen()
    end
end

function setScreen(targetScreen)
    screen = targetScreen
    if targetScreen == "index" then
        windowIndex.setVisible(true)
        windowRequest.setVisible(false)
        handleIndexScreen()
    elseif targetScreen == "request" then
        windowIndex.setVisible(false)
        windowRequest.setVisible(true)
        handleRequestScreen()
    end
    os.queueEvent("vault.screen_changed", targetScreen)
end

setScreen("index")