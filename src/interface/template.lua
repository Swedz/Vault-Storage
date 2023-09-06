local screen = {}

local windows = {}
screen.windows = windows

windows.main = window.create(term.current(), 1, 1, termWidth, termHeight, false)

function screen:open(args)
    -- Apply the arguments, if any
end

function screen:close()
    -- Run some close code, usually not applicable
end

function screen:draw()
    -- Draw the screen
end

function screen:event(event, eventData)
    -- Handle events
end

return screen