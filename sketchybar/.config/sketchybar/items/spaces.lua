-- items/spaces.lua
-- Aerospace workspace integration with rainbow colors and hover animations

local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Register aerospace workspace change event
sbar.add("event", "aerospace_workspace_change")

-- Store space items for later reference
local space_items = {}
local bracket_items = {}
local space_colors = {}  -- Store rainbow color for each workspace
local space_states = {}  -- Store current state (visible/has_windows)

-- Get app icon from mapping
local function get_app_icon(app_name)
    return app_icons[app_name] or ":default:"
end

-- Create a space item with rainbow color
local function create_space_item(workspace, label, sync_index)
    local space_name = "space." .. workspace
    local bracket_name = "space_bracket." .. workspace

    local home = os.getenv("HOME")
    local aerospace_config = home .. "/.config/aerospace"

    -- Get rainbow color for this workspace (based on label 1-10)
    local ws_color = colors.get_rainbow(tonumber(label) or workspace)
    space_colors[workspace] = ws_color
    space_states[workspace] = { visible = false, has_windows = false }

    -- Create space item
    local space = sbar.add("item", space_name, {
        position = "left",
        drawing  = false,
        background = {
            color         = colors.surface0,
            corner_radius = 5,
            height        = 24,
            border_width  = 1,
            border_color  = colors.with_alpha(ws_color, 0.3),
            drawing       = true,
        },
        label = {
            string        = label,
            font = {
                family = settings.font.label,
                style  = settings.font.style.regular,
                size   = 13.0,
            },
            color         = colors.with_alpha(ws_color, 0.6),
            padding_left  = 5,
            padding_right = 5,
        },
        icon = {
            drawing       = true,
            font = {
                family = settings.font.app,
                style  = settings.font.style.regular,
                size   = 16.0,
            },
            color         = colors.with_alpha(ws_color, 0.6),
            padding_left  = 6,
            padding_right = 6,
        },
        click_script = string.format('bash "%s/scripts/workspace-sync.sh" %d', aerospace_config, sync_index),
    })

    -- Create bracket for glow effect
    local bracket = sbar.add("bracket", bracket_name, { space_name }, {
        drawing = false,
        background = {
            color        = colors.transparent,
            border_color = colors.transparent,
            border_width = 2,
            corner_radius = 7,
            height       = 28,
        },
    })

    space_items[workspace] = space
    bracket_items[workspace] = bracket

    -- Subscribe to workspace change event
    space:subscribe("aerospace_workspace_change", function(env)
        update_space(workspace)
    end)

    -- Hover animation: mouse entered
    space:subscribe("mouse.entered", function(env)
        local state = space_states[workspace]
        if not state then return end

        sbar.animate("tanh", 15, function()
            if state.visible then
                -- Active: brighten and add glow
                space:set({
                    background = { height = 26 },
                    icon  = { color = colors.white },
                    label = { color = colors.white },
                })
                bracket:set({
                    background = { border_color = ws_color },
                })
            else
                -- Inactive: highlight with rainbow color
                space:set({
                    background = {
                        color = colors.with_alpha(ws_color, 0.2),
                        height = 26,
                    },
                    icon  = { color = ws_color },
                    label = { color = ws_color },
                })
                bracket:set({
                    background = { border_color = colors.with_alpha(ws_color, 0.5) },
                })
            end
        end)
    end)

    -- Hover animation: mouse exited
    space:subscribe("mouse.exited", function(env)
        local state = space_states[workspace]
        if not state then return end

        sbar.animate("tanh", 15, function()
            if state.visible then
                -- Restore active state
                space:set({
                    background = {
                        color  = ws_color,
                        height = 24,
                    },
                    icon  = { color = colors.crust },
                    label = { color = colors.crust },
                })
                bracket:set({
                    background = { border_color = colors.with_alpha(ws_color, 0.5) },
                })
            else
                -- Restore inactive state
                space:set({
                    background = {
                        color  = colors.surface0,
                        height = 24,
                    },
                    icon  = { color = colors.with_alpha(ws_color, 0.6) },
                    label = { color = colors.with_alpha(ws_color, 0.6) },
                })
                bracket:set({
                    background = { border_color = colors.transparent },
                })
            end
        end)
    end)

    return space, bracket
end

-- Update a single space item
function update_space(workspace)
    local space = space_items[workspace]
    local bracket = bracket_items[workspace]
    local ws_color = space_colors[workspace] or colors.blue

    if not space or not bracket then return end

    -- Get visible workspaces and windows
    sbar.exec("aerospace list-workspaces --monitor all --visible 2>/dev/null", function(visible_output)
        local is_visible = false
        if visible_output then
            for ws in visible_output:gmatch("%S+") do
                if ws == tostring(workspace) then
                    is_visible = true
                    break
                end
            end
        end

        sbar.exec("aerospace list-windows --workspace " .. workspace .. " 2>/dev/null", function(windows_output)
            local has_windows = windows_output and windows_output:match("%S") ~= nil

            -- Update state
            space_states[workspace] = { visible = is_visible, has_windows = has_windows }

            -- Show/hide logic
            if is_visible or has_windows then
                space:set({ drawing = true })
                bracket:set({ drawing = true })
            else
                space:set({ drawing = false })
                bracket:set({ drawing = false })
                return
            end

            -- Style based on visibility with rainbow colors
            if is_visible then
                -- Active workspace: full rainbow color
                sbar.animate("tanh", 20, function()
                    space:set({
                        background = {
                            color        = ws_color,
                            border_color = colors.with_alpha(ws_color, 0.8),
                        },
                        label = { color = colors.crust },
                        icon  = { color = colors.crust },
                    })
                    bracket:set({
                        background = { border_color = colors.with_alpha(ws_color, 0.5) },
                    })
                end)
            else
                -- Has windows but not visible: dimmed rainbow color
                sbar.animate("tanh", 20, function()
                    space:set({
                        background = {
                            color        = colors.surface0,
                            border_color = colors.with_alpha(ws_color, 0.3),
                        },
                        label = { color = colors.with_alpha(ws_color, 0.6) },
                        icon  = { color = colors.with_alpha(ws_color, 0.6) },
                    })
                    bracket:set({
                        background = { border_color = colors.transparent },
                    })
                end)
            end

            -- Collect app icons from windows
            local icons = {}
            if windows_output then
                for line in windows_output:gmatch("[^\r\n]+") do
                    local app_name = line:match("|%s*([^|]+)%s*|")
                    if app_name then
                        app_name = app_name:match("^%s*(.-)%s*$")
                        if app_name and app_name ~= "" then
                            local icon = get_app_icon(app_name)
                            table.insert(icons, icon)
                        end
                    end
                end
            end

            -- Update icon with animation
            sbar.animate("tanh", 10, function()
                space:set({
                    icon = { string = table.concat(icons, "") },
                })
            end)
        end)
    end)
end

-- Initialize spaces based on monitor configuration
local function init_spaces()
    sbar.exec("command -v aerospace", function(output)
        if not output or output == "" then
            return
        end

        sbar.exec("aerospace list-monitors --format '%{monitor-id} %{monitor-appkit-nsscreen-screens-id} %{monitor-is-main}' 2>/dev/null", function(monitors_output)
            if not monitors_output or monitors_output == "" then
                -- Fallback: create spaces 1-10 for single monitor
                for i = 1, 10 do
                    create_space_item(i, tostring(i), i)
                end
            else
                local main_display_id = nil
                local secondary_display_id = nil

                for line in monitors_output:gmatch("[^\r\n]+") do
                    local monitor_id, display_id, is_main = line:match("(%S+)%s+(%S+)%s+(%S+)")
                    if is_main == "true" then
                        main_display_id = display_id
                    elseif not secondary_display_id then
                        secondary_display_id = display_id
                    end
                end

                -- Create main display spaces (1-10)
                if main_display_id then
                    for i = 1, 10 do
                        create_space_item(i, tostring(i), i)
                    end
                end

                -- Create secondary display spaces (11-20, labeled as 1-10)
                if secondary_display_id then
                    for i = 1, 10 do
                        local workspace = i + 10
                        create_space_item(workspace, tostring(i), i)
                    end
                end
            end

            -- Create periodic refresh observer
            local refresh = sbar.add("item", "spaces_refresh", {
                position    = "left",
                drawing     = false,
                update_freq = 5,
            })

            refresh:subscribe("routine", function()
                sbar.trigger("aerospace_workspace_change")
            end)

            -- Delay initial trigger
            sbar.exec("sleep 0.5 && sketchybar --trigger aerospace_workspace_change")
        end)
    end)
end

-- Initialize on load
init_spaces()
