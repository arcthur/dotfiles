-- settings.lua
-- Global configuration constants

return {
    -- Fonts (loaded from helpers/fonts.lua for easy switching)
    font = require("helpers.fonts"),

    -- Update frequencies (seconds)
    update = {
        clock   = 1,
        fast    = 3,
        medium  = 60,
        slow    = 300,
    },

    -- Paddings
    paddings       = 5,
    group_paddings = 8,

    -- Icon type: "sf-symbols" or "nerdfont"
    icons = "nerdfont",
}
