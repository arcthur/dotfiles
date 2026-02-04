-- items/front_app.lua
-- Front application display (positioned after spaces)

local colors = require("colors")
local settings = require("settings")

-- Ensure the event exists (spaces.lua also registers it; this is idempotent)
sbar.add("event", "aerospace_workspace_change")

local SHELL_PATH = settings.shell_path or "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin"

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

local current_app_name = ""
local current_workspace = nil

local function lock_exists()
    local f = io.open(settings.locks.workspace_sync, "r")
    if f then f:close() return true end
    return false
end

local function normalize_workspace(workspace)
    if not workspace then return nil end
    if workspace > 10 then
        return workspace - 10
    end
    return workspace
end

local function set_label()
    if current_app_name == "" then return end

    local label = current_app_name
    if current_workspace then
        label = tostring(current_workspace) .. "::" .. current_app_name
    end

    front_app:set({ label = { string = label } })
end

local function refresh_workspace_and_label()
    sbar.exec("PATH=" .. SHELL_PATH .. " aerospace list-workspaces --focused 2>/dev/null", function(output)
        if output and output ~= "" then
            local workspace = tonumber(output:match("%d+"))
            current_workspace = normalize_workspace(workspace)
        end
        set_label()
    end)
end

-- Move front_app after spaces are initialized (spaces created async)
sbar.exec("sleep 1", function()
    sbar.exec("PATH=" .. SHELL_PATH .. " sketchybar --move front_app after space.10")
end)

-- Update front app on switch
front_app:subscribe("front_app_switched", function(env)
    current_app_name = env.INFO or ""
    if current_app_name == "" then return end

    -- Avoid reading workspace mid-sync (workspace event will update after sync completes)
    if lock_exists() then
        return
    end

    if current_workspace then
        set_label()
    else
        refresh_workspace_and_label()
    end
end)

-- Update workspace prefix on workspace change
front_app:subscribe("aerospace_workspace_change", function(env)
    if lock_exists() then
        return
    end

    local workspace = tonumber(env.FOCUSED_WORKSPACE or "")
    current_workspace = normalize_workspace(workspace)

    if current_workspace then
        set_label()
    else
        refresh_workspace_and_label()
    end
end)
