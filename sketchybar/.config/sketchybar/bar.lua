-- bar.lua
-- Bar configuration

local colors = require("colors")

sbar.bar({
    height        = 40,
    blur_radius   = 10,
    position      = "top",
    sticky        = true,
    padding_left  = 10,
    padding_right = 10,
    color         = colors.bar.bg,
    y_offset      = 0,
    margin        = 0,
    corner_radius = 0,
    border_width  = 0,
    border_color  = colors.lavender,
    shadow        = true,
})
