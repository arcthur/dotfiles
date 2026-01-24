-- helpers/fonts.lua
-- Font configuration for SketchyBar
--
-- Switch between font presets by changing the return value at the bottom

local fonts = {}

-- JetBrainsMono Nerd Font preset (default)
fonts.jetbrains = {
    text    = "JetBrainsMono Nerd Font",
    numbers = "JetBrainsMono Nerd Font",
    app     = "sketchybar-app-font",
    label   = "TX-02",
    style = {
        regular  = "Regular",
        semibold = "Semibold",
        bold     = "Bold",
    },
}

-- SF Pro + SF Mono preset (macOS native)
fonts.sf = {
    text    = "SF Pro",
    numbers = "SF Mono",
    app     = "sketchybar-app-font",
    label   = "SF Pro",
    style = {
        regular  = "Regular",
        semibold = "Semibold",
        bold     = "Bold",
    },
}

-- Hack Nerd Font preset
fonts.hack = {
    text    = "Hack Nerd Font",
    numbers = "Hack Nerd Font Mono",
    app     = "sketchybar-app-font",
    label   = "Hack Nerd Font",
    style = {
        regular  = "Regular",
        semibold = "Bold",
        bold     = "Bold",
    },
}

-- FiraCode preset
fonts.firacode = {
    text    = "FiraCode Nerd Font",
    numbers = "FiraCode Nerd Font",
    app     = "sketchybar-app-font",
    label   = "FiraCode Nerd Font",
    style = {
        regular  = "Regular",
        semibold = "Medium",
        bold     = "SemiBold",
    },
}

-- Export the currently selected font preset
-- Change this to switch fonts: fonts.sf, fonts.hack, fonts.firacode, etc.
return fonts.jetbrains
