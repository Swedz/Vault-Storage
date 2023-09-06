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

config = require("config")
require("core")
depositor = require("depositor"):setup()

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

interfaceutils = require("interface/interfaceutils")
interfaces = require("interface/interfaces")

interfaces:setScreen("index")