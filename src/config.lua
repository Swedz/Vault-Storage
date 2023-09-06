return {
    debug = true,
    -- All peripherals of this type should be used as inventories. Use nil to use none
    inventory_peripheral = nil,
    -- Array of peripheral names that should be added to the peripheral list.
    -- Accepts Lua patterns (https://www.lua.org/pil/20.1.html)
    additional_inventory_peripherals = {
        "sophisticatedstorage:.*"
    },
    -- Depositors are inventories that will every X seconds be pulled from and inserted into the main system
    depositors = {
        -- The amount of seconds waited in between every deposit.
        -- This will automatically be rounded up to the nearest multiple of 0.05, as it waits for a fixed amount of world ticks.
        frequency = 0.25,
        -- Array of patterns that will be used to find inventory peripherals to use as depositors.
        -- Inventories matching the inserter patterns will not be registered as inventory peripherals.
        -- Accepts Lua patterns (https://www.lua.org/pil/20.1.html)
        inserters = {
            "minecraft:chest.*",
            "minecraft:barrel.*"
        }
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