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
    for slot, protected in pairs(protected_slots) do
        local item = turtle.getItemDetail(slot)
        if protected and not item then
            protected_slots[slot] = false
        elseif not protected and item then
            cache:depositItems(computerName, slot)
            drawIndexScreen()
            sleep(0.05)
        end
    end
end