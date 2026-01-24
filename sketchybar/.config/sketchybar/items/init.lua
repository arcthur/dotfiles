-- items/init.lua
-- Load all bar items (order matches original bash config)

-- Left side items
require("items.spaces")
require("items.front_app")

-- Right side items
require("items.aerospace_mode")
require("items.weather")

-- Widgets: network, battery, storage, cpu, ram
require("items.widgets")
