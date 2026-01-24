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

-- ============================================================================
-- Regex Batch Update Helpers
-- ============================================================================

-- Batch set properties on all space items matching regex pattern
local function batch_set_spaces(props)
    sbar.set("/space\\..*/", props)
end

-- Batch set properties on all bracket items matching regex pattern
local function batch_set_brackets(props)
    sbar.set("/space_bracket\\..*/", props)
end

-- Hide all spaces (used before showing only visible ones)
local function hide_all_spaces()
    batch_set_spaces({ drawing = false })
    batch_set_brackets({ drawing = false })
end

-- ============================================================================
-- Bulk Update: Update all workspaces in one efficient operation
-- ============================================================================

local function update_all_spaces()
    -- Get visible workspaces and all window info in parallel via a single script
    local cmd = [[
        visible=$(aerospace list-workspaces --monitor all --visible 2>/dev/null | tr '\n' ' ')
        echo "VISIBLE:$visible"
        for ws in $(aerospace list-workspaces --monitor all 2>/dev/null); do
            windows=$(aerospace list-windows --workspace "$ws" 2>/dev/null)
            if [ -n "$windows" ]; then
                echo "HAS_WINDOWS:$ws"
            fi
        done
    ]]

    sbar.exec(cmd, function(output)
        if not output then return end

        -- Parse visible workspaces
        local visible_set = {}
        local visible_line = output:match("VISIBLE:([^\n]*)")
        if visible_line then
            for ws in visible_line:gmatch("%S+") do
                visible_set[ws] = true
            end
        end

        -- Parse workspaces with windows
        local has_windows_set = {}
        for ws in output:gmatch("HAS_WINDOWS:(%S+)") do
            has_windows_set[ws] = true
        end

        -- Step 1: Batch hide all spaces first
        hide_all_spaces()

        -- Step 2: Update only visible/active spaces individually
        for workspace, space in pairs(space_items) do
            local ws_str = tostring(workspace)
            local is_visible = visible_set[ws_str]
            local has_windows = has_windows_set[ws_str]
            local bracket = bracket_items[workspace]
            local ws_color = space_colors[workspace] or colors.blue

            -- Update state
            space_states[workspace] = { visible = is_visible, has_windows = has_windows }

            if is_visible or has_windows then
                -- Show this space
                space:set({ drawing = true })
                if bracket then bracket:set({ drawing = true }) end

                -- Apply appropriate style
                if is_visible then
                    space:set({
                        background = {
                            color        = ws_color,
                            border_color = colors.with_alpha(ws_color, 0.8),
                            height       = 24,
                        },
                        label = { color = colors.crust },
                        icon  = { color = colors.crust },
                    })
                    if bracket then
                        bracket:set({
                            background = { border_color = colors.with_alpha(ws_color, 0.5) },
                        })
                    end
                else
                    space:set({
                        background = {
                            color        = colors.surface0,
                            border_color = colors.with_alpha(ws_color, 0.3),
                            height       = 24,
                        },
                        label = { color = colors.with_alpha(ws_color, 0.6) },
                        icon  = { color = colors.with_alpha(ws_color, 0.6) },
                    })
                    if bracket then
                        bracket:set({
                            background = { border_color = colors.transparent },
                        })
                    end
                end
            end
        end

        -- Step 3: Update icons for spaces with windows (async, parallel)
        for workspace, _ in pairs(has_windows_set) do
            local ws_num = tonumber(workspace)
            if ws_num and space_items[ws_num] then
                sbar.exec("aerospace list-windows --workspace " .. workspace .. " 2>/dev/null", function(windows_output)
                    local icons = {}
                    if windows_output then
                        for line in windows_output:gmatch("[^\r\n]+") do
                            local app_name = line:match("|%s*([^|]+)%s*|")
                            if app_name then
                                app_name = app_name:match("^%s*(.-)%s*$")
                                if app_name and app_name ~= "" then
                                    local icon = app_icons[app_name] or ":default:"
                                    table.insert(icons, icon)
                                end
                            end
                        end
                    end
                    space_items[ws_num]:set({
                        icon = { string = table.concat(icons, "") },
                    })
                end)
            end
        end
    end)
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

    -- NOTE: Workspace change is now handled by a single global observer
    -- that calls update_all_spaces() for efficient batch updates

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

            -- Create global workspace observer (single observer for batch updates)
            local workspace_observer = sbar.add("item", "spaces_observer", {
                position    = "left",
                drawing     = false,
                update_freq = 5,
            })

            -- Subscribe to workspace change event - uses efficient bulk update
            workspace_observer:subscribe("aerospace_workspace_change", function()
                update_all_spaces()
            end)

            -- Periodic refresh for sync
            workspace_observer:subscribe("routine", function()
                update_all_spaces()
            end)

            -- Delay initial update
            sbar.exec("sleep 0.5", function()
                update_all_spaces()
            end)
        end)
    end)
end

-- Initialize on load
init_spaces()
