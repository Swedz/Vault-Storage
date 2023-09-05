return {
    debug = true,
    -- All peripherals of this type should be used as inventories. Use nil to use none
    inventory_peripheral = nil,
    -- Array of peripheral names that should be added to the peripheral list.
    -- Accepts Lua patterns (https://www.lua.org/pil/20.1.html)
    additional_inventory_peripherals = {
        "sophisticatedstorage:.*"
    },
    -- The item inserter inventory peripheral names to wrap and continually pull items from and insert into the system.
    -- Inventories matching the item inserter patterns will not be registered as inventory peripherals.
    -- Accepts Lua patterns (https://www.lua.org/pil/20.1.html)
    item_inserters = {
        "minecraft:chest.*",
        "minecraft:barrel.*"
    },
    colors = {
        indexSearchBox = {
            background = colors.white,
            text = colors.black
        },
        indexHeader = {
            background = colors.lightGray,
            text = colors.white
        },
        indexHighlightedEntry = {
            background = colors.lightGray,
            text = colors.white
        },
        indexContent = {
            background = colors.gray,
            text = colors.white
        },
        indexInfo = {
            background = colors.black,
            text = colors.yellow
        },
        requestItems = {
            background = colors.gray,
            text = colors.white
        },
        requestItemsAmount = {
            background = colors.white,
            text = colors.black
        }
    }
}