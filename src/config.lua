return {
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
        tabs = {
            selected = {
                background = colors.white,
                text = colors.lightGray
            },
            deselected = {
                background = colors.gray,
                text = colors.white
            }
        },
        index = {
            search = {
                background = colors.white,
                text = colors.black
            },
            header = {
                background = colors.lightGray,
                text = colors.white
            },
            highlightedEntry = {
                background = colors.lightGray,
                text = colors.white
            },
            content = {
                background = colors.gray,
                text = colors.white
            }
        },
        index_request = {
            body = {
                background = colors.gray,
                text = colors.white
            },
            input = {
                background = colors.white,
                text = colors.black
            }
        },
        details = {
            body = {
                background = colors.gray,
                text = colors.white
            },
            split = {
                background = colors.white,
                text = colors.black
            }
        },
        manual = {
            body = {
                background = colors.gray,
                text = colors.white
            },
            split = {
                background = colors.white
            }
        }
    },
    -- Developer only options. Do not touch these, unless you know what you're doing.
    version = "1",
    debug = true
}