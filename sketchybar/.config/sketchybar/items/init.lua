-- items/init.lua
-- Load all bar items (order matches original bash config)

-- Left side items (spaces.sh includes apple menu)
require("items.apple")
require("items.spaces")
require("items.front_app")

-- Right side items (clock.sh includes weather/temp)
require("items.clock")

-- Widgets: wifi, network, battery, storage, cpu, ram
require("items.widgets")
