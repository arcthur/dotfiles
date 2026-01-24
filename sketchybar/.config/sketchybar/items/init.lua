-- items/init.lua
-- Load all bar items

-- Left side items
require("items.apple")
require("items.spaces")
require("items.front_app")

-- Right side items (load in reverse order for proper positioning)
require("items.clock")
require("items.weather")

-- Widgets (system monitoring)
require("items.widgets")
