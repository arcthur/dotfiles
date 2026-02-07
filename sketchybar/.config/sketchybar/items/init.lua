-- items/init.lua
-- Load all bar items (order matches original bash config)

local wm = require("helpers.wm")

-- Left side items (WM-aware space indicators)
if wm.type == "aerospace" then
    require("items.spaces")
end
require("items.front_app")
require("items.spotify")

-- Right side items (position="right" adds from right to left)
if wm.type == "aerospace" then
    require("items.aerospace_mode")
end
require("items.weather")

-- Widgets: network, battery, storage, cpu, ram
require("items.widgets")
