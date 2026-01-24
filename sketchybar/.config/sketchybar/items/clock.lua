-- items/clock.lua
-- Clock display

local colors = require("colors")
local settings = require("settings")

-- Clock item
local clock = sbar.add("item", "clock", {
    position    = "right",
    update_freq = settings.update.clock,
    icon = {
        string = "󰃰 ",
        font = {
            family = settings.font.text,
            style  = settings.font.style.bold,
            size   = 14.0,
        },
        color = colors.red,
    },
    label = {
        font = {
            family = settings.font.label,
            style  = settings.font.style.regular,
            size   = 13.0,
        },
    },
    click_script = "open -a 'Calendar'",
})

-- Utils bracket (groups clock and temp)
sbar.add("bracket", "utils", { "clock", "temp" }, {
    background = {
        color         = colors.surface0,
        corner_radius = 7,
        height        = 32,
    },
    shadow = false,
})

-- Divider after utils bracket
sbar.add("item", "divider", {
    position = "right",
    width    = 8,
    background = { drawing = false },
    icon     = { drawing = false },
    label    = { drawing = false },
})

-- Update clock
clock:subscribe({ "routine", "forced", "system_woke" }, function()
    clock:set({
        label = os.date("%a %d %I:%M %p"),
    })
end)
