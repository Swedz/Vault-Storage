return {
    debug = true,
    -- All peripherals of this type should be used as inventories. Use nil to use none
    inventory_peripheral = "minecraft:barrel",
    -- Array of peripheral names that should be added to the peripheral list
    additional_inventory_peripherals = {},
    modem_port = {
        -- The port the server will listen on, in other words, the port the client will send to to make requests
        server = 69,
        -- The port the client will listen on, in other words, the port the server will send to to respond to requests
        client = 68
    },
    colors = {
        searchBox = {
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
        }
    }
}