-- items/clock.lua
-- Clock display

local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

-- Clock item
local clock = sbar.add("item", "clock", {
    position   = "right",
    update_freq = settings.update.clock,
    icon = {
        string = icons.clock .. " ",
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

-- Update clock on routine/forced events
clock:subscribe({ "routine", "forced", "system_woke" }, function(env)
    clock:set({
        label = os.date("%a %d %I:%M %p"),
    })
end)
