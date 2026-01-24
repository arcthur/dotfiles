-- settings.lua
-- Global configuration constants

return {
    -- Fonts
    font = {
        text    = "JetBrainsMono Nerd Font",
        numbers = "JetBrainsMono Nerd Font",
        app     = "sketchybar-app-font",
        label   = "TX-02",
        style = {
            regular  = "Regular",
            semibold = "Semibold",
            bold     = "Bold",
        },
    },

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
