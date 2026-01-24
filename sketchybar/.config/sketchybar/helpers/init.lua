-- helpers/init.lua
-- Helper utilities and constants

local M = {}

local home = os.getenv("HOME")

-- Global config directory
M.config_dir = home .. "/.config/sketchybar"
M.plugin_dir = M.config_dir .. "/plugins"

return M
