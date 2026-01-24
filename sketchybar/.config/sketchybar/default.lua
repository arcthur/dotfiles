-- default.lua
-- Default item configuration

local colors = require("colors")
local settings = require("settings")

sbar.default({
    -- Performance optimizations
    updates = "when_shown",  -- Only update when item is visible
    scroll_texts = true,      -- Enable text scrolling for long labels

    icon = {
        font = {
            family = settings.font.text,
            style  = settings.font.style.bold,
            size   = 17.0,
        },
        color         = colors.white,
        padding_left  = 4,
        padding_right = 4,
        y_offset      = 0,
    },
    label = {
        font = {
            family = settings.font.label,
            style  = settings.font.style.regular,
            size   = 13.0,
        },
        color         = colors.white,
        padding_left  = 4,
        padding_right = 4,
        y_offset      = 0,
    },
    padding_left  = 5,
    padding_right = 5,
    background = {
        height        = 32,
        corner_radius = 5,
        border_width  = 1,
        border_color  = colors.bar.border,
        y_offset      = 0,
    },
    popup = {
        background = {
            border_width  = 1,
            corner_radius = 5,
            border_color  = colors.popup.border,
            color         = colors.popup.bg,
            shadow = {
                drawing = true,
            },
        },
        blur_radius = 32,
    },
})
