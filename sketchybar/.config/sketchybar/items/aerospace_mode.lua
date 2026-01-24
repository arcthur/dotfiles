-- items/aerospace_mode.lua
-- Display current aerospace mode (PREFIX, RESIZE, etc.)

local colors = require("colors")
local settings = require("settings")

-- Register custom events for mode display
sbar.add("event", "aerospace_mode_change")

-- Aerospace mode indicator
local aerospace_mode = sbar.add("item", "aerospace_mode", {
    position = "right",
    drawing  = false,  -- Hidden by default
    icon = {
        drawing = false,
    },
    label = {
        font = {
            family = settings.font.text,
            style  = settings.font.style.bold,
            size   = 12.0,
        },
        color      = colors.base,
        padding_left  = 8,
        padding_right = 8,
    },
    background = {
        color         = colors.mauve,
        corner_radius = 4,
        height        = 20,
    },
})

-- Handle mode change events
aerospace_mode:subscribe("aerospace_mode_change", function(env)
    local mode = env.MODE or ""

    if mode == "" or mode == "main" then
        -- Hide when in main mode
        aerospace_mode:set({ drawing = false })
    else
        -- Show mode label with appropriate color
        local bg_color = colors.mauve
        local label = "[" .. mode:upper() .. "]"

        if mode == "prefix" then
            bg_color = colors.mauve
        elseif mode == "resize" then
            bg_color = colors.peach
        elseif mode == "move" then
            bg_color = colors.blue
        elseif mode == "service" then
            bg_color = colors.red
        end

        aerospace_mode:set({
            drawing = true,
            label   = { string = label },
            background = { color = bg_color },
        })
    end
end)
