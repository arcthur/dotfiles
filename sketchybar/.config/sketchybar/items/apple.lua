-- items/apple.lua
-- Apple menu with popup

local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

local POPUP_TOGGLE = "sketchybar --set $NAME popup.drawing=toggle"
local POPUP_OFF = "sketchybar --set apple.logo popup.drawing=off"

-- Apple logo item
local apple = sbar.add("item", "apple.logo", {
    position = "left",
    icon = {
        string = icons.apple,
        font = {
            family = settings.font.text,
            style  = settings.font.style.bold,
            size   = 23.0,
        },
        color         = colors.peach,
        padding_left  = 10,
        padding_right = 10,
    },
    padding_right = 15,
    label = { drawing = false },
    click_script = POPUP_TOGGLE,
    popup = { height = 35 },
    background = { drawing = false },
    shadow = false,
})

-- Popup menu items
local popup_items = {
    {
        name   = "prefs",
        icon   = icons.preferences,
        label  = "Preferences",
        script = "open -a 'System Preferences'; " .. POPUP_OFF,
    },
    {
        name   = "activity",
        icon   = icons.activity,
        label  = "Activity",
        script = "open -a 'Activity Monitor'; " .. POPUP_OFF,
    },
    {
        name   = "lock",
        icon   = icons.lock,
        label  = "Lock Screen",
        script = "pmset displaysleepnow; " .. POPUP_OFF,
    },
    {
        name   = "off",
        icon   = "⏻",
        label  = "Shut Down",
        script = "osascript -e 'tell app \"System Events\" to shut down'; " .. POPUP_OFF,
    },
}

for _, item in ipairs(popup_items) do
    sbar.add("item", "apple." .. item.name, {
        position = "popup.apple.logo",
        icon     = { string = item.icon },
        label    = { string = item.label },
        click_script = item.script,
    })
end
