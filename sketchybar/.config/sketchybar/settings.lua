-- settings.lua
-- Global configuration constants

local home = os.getenv("HOME")

return {
    -- Fonts (loaded from helpers/fonts.lua for easy switching)
    font = require("helpers.fonts"),

    -- Update frequencies (seconds)
    update = {
        clock   = 1,
        fast    = 3,
        medium  = 60,
        slow    = 300,
    },

    -- Paddings
    paddings       = 5,
    group_paddings = 8,

    -- Icon type: "sf-symbols" or "nerdfont"
    icons = "nerdfont",

    -- Cache/temp files directory
    cache_dir = os.getenv("SKETCHYBAR_CACHE_DIR") or "/tmp",

    -- Lock files
    locks = {
        workspace_sync = "/tmp/aerospace_workspace_sync_lock",
    },

    -- Shell PATH prefix for launchd apps (Homebrew + system)
    shell_path = "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin",
}
