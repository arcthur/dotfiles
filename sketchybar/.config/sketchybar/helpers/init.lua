-- helpers/init.lua
-- Setup module paths for SbarLua

local home = os.getenv("HOME")

-- Add SbarLua to package path
package.cpath = package.cpath .. ";" .. home .. "/.local/share/sketchybar_lua/?.so"

-- Set global config directory
CONFIG_DIR = home .. "/.config/sketchybar"

-- Load SbarLua
sbar = require("sketchybar")

-- Start the event loop at the end of config
sbar.begin_config()
