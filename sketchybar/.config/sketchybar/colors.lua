-- colors.lua
-- Catppuccin Mocha Palette
-- https://github.com/catppuccin/catppuccin

return {
    -- Accent Colors
    rosewater = 0xfff5e0dc,
    flamingo  = 0xfff2cdcd,
    pink      = 0xfff5c2e7,
    mauve     = 0xffcba6f7,
    red       = 0xfff38ba8,
    maroon    = 0xffeba0ac,
    peach     = 0xfffab387,
    yellow    = 0xfff9e2af,
    green     = 0xffa6e3a1,
    teal      = 0xff94e2d5,
    sky       = 0xff89dceb,
    sapphire  = 0xff74c7ec,
    blue      = 0xff89b4fa,
    lavender  = 0xffb4befe,

    -- Neutral Colors
    text      = 0xffcdd6f4,
    subtext1  = 0xffbac2de,
    subtext0  = 0xffa6adc8,
    overlay2  = 0xff9399b2,
    overlay1  = 0xff7f849c,
    overlay0  = 0xff6c7086,
    surface2  = 0xff585b70,
    surface1  = 0xff45475a,
    surface0  = 0xff313244,
    base      = 0xff1e1e2e,
    mantle    = 0xff181825,
    crust     = 0xff11111b,

    -- Special
    transparent = 0x00000000,
    white       = 0xffffffff,

    -- Semi-transparent
    overlay2_50 = 0x559399b2,

    -- Bar Styling
    bar = {
        bg     = 0x50000000,    -- BAR_TRANSPARENT
        border = 0xff45475a,    -- SURFACE1
    },

    popup = {
        bg     = 0xff1e1e2e,    -- BASE
        border = 0xff89b4fa,    -- BLUE
    },

    highlight    = 0x44ffffff,
    background_1 = 0x60313244,

    -- Utility function: apply alpha to color
    with_alpha = function(color, alpha)
        if alpha > 1.0 or alpha < 0.0 then return color end
        local r = (color >> 16) & 0xFF
        local g = (color >> 8) & 0xFF
        local b = color & 0xFF
        return (math.floor(alpha * 255.0 + 0.5) << 24) | (r << 16) | (g << 8) | b
    end,
}
