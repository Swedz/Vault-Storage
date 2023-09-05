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

function handleTurtleInventory()
    local queue = {}

    for slot, protected in pairs(protected_slots) do
        local item = turtle.getItemDetail(slot)
        if protected and not item then
            protected_slots[slot] = false
        elseif not protected and item then
            table.insert(queue, function()
                cache:depositItems(computerName, slot)
                drawScreen()
            end)
        end
    end

    processQueue(queue)
end