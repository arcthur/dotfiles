-- items/widgets/wifi.lua
-- WiFi status indicator

local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

-- WiFi item
local wifi = sbar.add("item", "wifi", {
    position = "right",
    icon = {
        string = icons.wifi,
        font = {
            family = settings.font.text,
            style  = settings.font.style.bold,
            size   = 19.0,
        },
        color         = colors.teal,
        padding_left  = 2,
        padding_right = 7,
    },
    background = {
        padding_right = 1,
    },
    click_script = "open 'x-apple.systempreferences:com.apple.Network-Settings.extension'",
})
