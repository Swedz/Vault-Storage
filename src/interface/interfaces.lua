Interfaces = {
    current = nil,
    screens = {
        index = require("../vault/interface/index/index"),
        index_request = require("../vault/interface/index/request")
        --details = require("../vault/interface/details")
        --manual = require("../vault/interface/manual")
    }
}

function Interfaces:setScreen(screenName, args)
    if self.screens[screenName] == nil then
        error("Could not find registered screen for name '" .. screenName .. "'")
    end

    if self.current ~= nil then
        self.screens[self.current]:close()
    end

    self.current = screenName
    local screen = self.screens[screenName]
    screen:open(args)
    screen:draw()

    depositor:start()

    while self.current == screenName do
        local function tickMain()
            while self.current == screenName do
                local eventData = { os.pullEvent() }
                local event = eventData[1]
                screen:event(event, eventData)
                if self.current == screenName then
                    screen:draw()
                end
            end
        end

        local function tickItemInserter()
            depositor:run(function() return self.current == screenName end)
        end

        parallel.waitForAll(tickMain, tickItemInserter)
    end
end

function Interfaces:forceDrawScreen()
    self.screens[self.current]:draw()
end

return Interfaces