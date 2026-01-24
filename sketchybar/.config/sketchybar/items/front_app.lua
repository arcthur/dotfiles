-- items/front_app.lua
-- Front application display

local colors = require("colors")
local settings = require("settings")

-- Separator between spaces and front app
local separator = sbar.add("item", "space_separator", {
    position = "left",
    icon = {
        string        = "󰡙",
        color         = colors.peach,
        padding_left  = 7,
        padding_right = 7,
    },
    label = { drawing = false },
})

-- Front app item
local front_app = sbar.add("item", "front_app", {
    position = "left",
    icon = { drawing = false },
    label = {
        font = {
            family = settings.font.label,
            style  = settings.font.style.regular,
            size   = 13.0,
        },
    },
    background = {
        height       = 22,
        color        = colors.overlay2,
        border_width = 0,
    },
    padding_right = 10,
})

-- Left side bracket
sbar.add("bracket", "left_side", { "front_app" }, {
    background = {
        padding_right = 32,
    },
})

-- Spaces group bracket (will be populated by spaces.lua)
sbar.add("bracket", "spaces_group", { "/space\\..*/" , "space_separator", "left_side" }, {
    background = {
        color         = colors.surface0,
        padding_right = 19,
    },
    shadow = false,
})

-- Update front app on switch
front_app:subscribe("front_app_switched", function(env)
    -- Check for sync lock (prevents update during workspace switch)
    local lock_file = io.open(settings.locks.workspace_sync, "r")
    if lock_file then
        lock_file:close()
        return
    end

    local app_name = env.INFO or ""

    -- Get current workspace
    sbar.exec("aerospace list-workspaces --focused 2>/dev/null", function(output)
        local workspace = tonumber(output:match("%d+"))

        -- Normalize: 11-20 → 1-10
        if workspace and workspace > 10 then
            workspace = workspace - 10
        end

        local label = app_name
        if workspace then
            label = workspace .. "::" .. app_name
        end

        front_app:set({
            label = { string = label },
        })
    end)
end)
