-- items/spaces.lua
-- Aerospace workspace integration with vertical pill style (BenjaminBini inspired)

local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Register aerospace workspace change event
sbar.add("event", "aerospace_workspace_change")

-- Store space items for later reference
local space_items = {}
local space_colors = {}  -- Store rainbow color for each workspace
local space_states = {}  -- Store current state (visible/has_windows)

-- ============================================================================
-- Style Constants (BenjaminBini vertical pill style)
-- ============================================================================

local PILL_HEIGHT_UNFOCUSED = 10
local PILL_HEIGHT_FOCUSED = 62
local PILL_Y_OFFSET = 18
local ANIMATION_DURATION = 10

-- ============================================================================
-- Regex Batch Update Helpers
-- ============================================================================

-- Batch set properties on all space items matching regex pattern
local function batch_set_spaces(props)
    sbar.set("/space\\..*/", props)
end

-- Hide all spaces
local function hide_all_spaces()
    batch_set_spaces({ drawing = false })
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
            local ws_color = space_colors[workspace] or colors.blue

            -- Update state
            space_states[workspace] = { visible = is_visible, has_windows = has_windows }

            if is_visible or has_windows then
                -- Show this space
                space:set({ drawing = true })

                -- Apply vertical pill style with animation
                sbar.animate("tanh", ANIMATION_DURATION, function()
                    if is_visible then
                        -- Focused: tall pill with full color
                        space:set({
                            background = {
                                color  = ws_color,
                                height = PILL_HEIGHT_FOCUSED,
                            },
                            icon = { color = colors.crust },
                        })
                    else
                        -- Has windows but not focused: short pill
                        space:set({
                            background = {
                                color  = colors.with_alpha(ws_color, 0.3),
                                height = PILL_HEIGHT_UNFOCUSED,
                            },
                            icon = { color = colors.with_alpha(ws_color, 0.6) },
                        })
                    end
                end)
            end
        end

        -- Step 3: Update icons for spaces with windows (show app icons)
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
                    -- Only show first icon to keep pill compact
                    local display_icon = icons[1] or ""
                    space_items[ws_num]:set({
                        icon = { string = display_icon },
                    })
                end)
            end
        end
    end)
end

-- Create a space item with vertical pill style
local function create_space_item(workspace, label, sync_index)
    local space_name = "space." .. workspace

    local home = os.getenv("HOME")
    local aerospace_config = home .. "/.config/aerospace"

    -- Get rainbow color for this workspace (based on label 1-10)
    local ws_color = colors.get_rainbow(tonumber(label) or workspace)
    space_colors[workspace] = ws_color
    space_states[workspace] = { visible = false, has_windows = false }

    -- Create space item with vertical pill style
    local space = sbar.add("item", space_name, {
        position = "left",
        drawing  = false,
        padding_left  = 4,
        padding_right = 4,
        background = {
            color         = colors.with_alpha(ws_color, 0.3),
            corner_radius = 5,
            height        = PILL_HEIGHT_UNFOCUSED,
            y_offset      = PILL_Y_OFFSET,
            border_width  = 0,
            drawing       = true,
        },
        icon = {
            string        = label,
            drawing       = true,
            font = {
                family = settings.font.label,
                style  = settings.font.style.semibold,
                size   = 12.0,
            },
            color         = colors.with_alpha(ws_color, 0.6),
            padding_left  = 6,
            padding_right = 6,
            y_offset      = -8,  -- Position icon at bottom of pill
        },
        label = { drawing = false },  -- No label, icon-only
        click_script = string.format('bash "%s/scripts/workspace-sync.sh" %d', aerospace_config, sync_index),
    })

    space_items[workspace] = space

    -- NOTE: Workspace change is now handled by a single global observer
    -- that calls update_all_spaces() for efficient batch updates

    -- Hover animation: mouse entered - grow pill
    space:subscribe("mouse.entered", function(env)
        local state = space_states[workspace]
        if not state then return end

        sbar.animate("tanh", ANIMATION_DURATION, function()
            if state.visible then
                -- Already focused, just brighten
                space:set({
                    background = { height = PILL_HEIGHT_FOCUSED + 4 },
                    icon = { color = colors.white },
                })
            else
                -- Inactive: grow and highlight
                space:set({
                    background = {
                        color  = colors.with_alpha(ws_color, 0.5),
                        height = PILL_HEIGHT_UNFOCUSED + 20,
                    },
                    icon = { color = ws_color },
                })
            end
        end)
    end)

    -- Hover animation: mouse exited - restore pill
    space:subscribe("mouse.exited", function(env)
        local state = space_states[workspace]
        if not state then return end

        sbar.animate("tanh", ANIMATION_DURATION, function()
            if state.visible then
                -- Restore focused state
                space:set({
                    background = {
                        color  = ws_color,
                        height = PILL_HEIGHT_FOCUSED,
                    },
                    icon = { color = colors.crust },
                })
            else
                -- Restore inactive state
                space:set({
                    background = {
                        color  = colors.with_alpha(ws_color, 0.3),
                        height = PILL_HEIGHT_UNFOCUSED,
                    },
                    icon = { color = colors.with_alpha(ws_color, 0.6) },
                })
            end
        end)
    end)

    return space
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
