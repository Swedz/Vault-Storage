term.clear()
term.setCursorPos(1, 1)
print("Indexing...")

termWidth, termHeight = nil
function updateTermSize()
    termWidth, termHeight = term.getSize()
end
updateTermSize()

require("core")
require("turtle_inventory")

screen = "index"
computerName = peripheral.find("modem").getNameLocal()
cache = require("items"):fullSetup()

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