-- init.lua
-- Main initialization file

-- Load configuration modules
require("colors")
require("settings")
require("icons")

-- Configure bar and defaults
require("bar")
require("default")

-- Load all items
require("items")

-- Finalize configuration
sbar.hotload(true)
sbar.end_config()

-- Trigger initial update
sbar.trigger("forced")
