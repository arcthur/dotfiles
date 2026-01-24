-- items/front_app.lua
-- Front application display (positioned after spaces)

local colors = require("colors")
local settings = require("settings")

-- Front app item - will be moved after spaces are created
local front_app = sbar.add("item", "front_app", {
    position = "left",
    icon = { drawing = false },
    label = {
        font = {
            family = settings.font.label,
            style  = settings.font.style.regular,
            size   = 13.0,
        },
        color = colors.text,
        padding_left = 8,
    },
    background = { drawing = false },
    padding_left = 4,
})

-- Move front_app after spaces are initialized (spaces created async)
sbar.exec("sleep 1", function()
    sbar.exec("sketchybar --move front_app after space.10")
end)

-- Update front app on switch
front_app:subscribe("front_app_switched", function(env)
    -- Check for sync lock (prevents update during workspace switch)
    local lock_file = io.open(settings.locks.workspace_sync, "r")
    if lock_file then
        lock_file:close()
        return
    end

    local app_name = env.INFO or ""

    -- Get current workspace and format as "workspace::app_name"
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
