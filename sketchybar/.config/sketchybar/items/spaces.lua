-- items/spaces.lua
-- Aerospace workspace integration with vertical pill style (BenjaminBini inspired)
-- Supports cross-monitor workspace merging: workspace N and N+10 are displayed as one item

local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Register aerospace workspace change event
sbar.add("event", "aerospace_workspace_change")

-- Store space items for later reference (only 1-10, representing merged workspaces)
local space_items = {}
local space_colors = {}  -- Store rainbow color for each workspace
local space_states = {}  -- Store current state (visible/has_windows)

-- ============================================================================
-- Style Constants
-- ============================================================================

local PILL_HEIGHT_UNFOCUSED = 6
local PILL_HEIGHT_FOCUSED = 64
local PILL_Y_OFFSET = 20
local ANIMATION_DURATION = 10

-- ============================================================================
-- Helper: Update a single space's icon/label based on windows
-- ============================================================================

local function update_space_icons(space, space_index, has_windows_set)
    local ws_primary = tostring(space_index)
    local ws_secondary = tostring(space_index + 10)
    local has_windows_primary = has_windows_set[ws_primary]
    local has_windows_secondary = has_windows_set[ws_secondary]

    -- No windows in either workspace - just show number, hide label
    if not has_windows_primary and not has_windows_secondary then
        space:set({
            icon = {
                string = tostring(space_index),
                font = {
                    family = settings.font.label,
                    style = settings.font.style.regular,
                    size = 13.0,
                },
            },
            label = { drawing = false },
        })
        return
    end

    -- Has windows - fetch and display app icons
    local cmd_windows = ""
    if has_windows_primary then
        cmd_windows = "aerospace list-windows --workspace " .. ws_primary .. " 2>/dev/null"
    end
    if has_windows_secondary then
        if cmd_windows ~= "" then
            cmd_windows = cmd_windows .. " && "
        end
        cmd_windows = cmd_windows .. "aerospace list-windows --workspace " .. ws_secondary .. " 2>/dev/null"
    end

    sbar.exec(cmd_windows, function(windows_output)
        local icons = {}
        local seen_icons = {}  -- Deduplicate icons
        if windows_output then
            for line in windows_output:gmatch("[^\r\n]+") do
                local app_name = line:match("|%s*([^|]+)%s*|")
                if app_name then
                    app_name = app_name:match("^%s*(.-)%s*$")
                    if app_name and app_name ~= "" then
                        local icon = app_icons[app_name] or ":default:"
                        if not seen_icons[icon] then
                            seen_icons[icon] = true
                            table.insert(icons, icon)
                        end
                    end
                end
            end
        end

        space:set({
            icon = {
                string = tostring(space_index),
                font = {
                    family = settings.font.label,
                    style = settings.font.style.regular,
                    size = 13.0,
                },
            },
            label = {
                drawing = true,
                string = table.concat(icons, " "),
                font = "sketchybar-app-font:Regular:13.0",
                padding_left = 4,
                padding_right = 6,
            },
        })
    end)
end

-- ============================================================================
-- Bulk Update: Update all workspaces in one efficient operation
-- ============================================================================

local function update_all_spaces()
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

        -- Update each merged space (1-10, each representing N and N+10)
        for i = 1, 10 do
            local space = space_items[i]
            if not space then goto continue end

            local ws_primary = tostring(i)
            local ws_secondary = tostring(i + 10)

            -- Check both workspaces for visibility and windows
            local is_visible_primary = visible_set[ws_primary]
            local is_visible_secondary = visible_set[ws_secondary]
            local has_windows_primary = has_windows_set[ws_primary]
            local has_windows_secondary = has_windows_set[ws_secondary]

            -- Merged state (explicit boolean to avoid nil issues)
            local is_visible = (is_visible_primary or is_visible_secondary) and true or false
            local has_windows = (has_windows_primary or has_windows_secondary) and true or false
            local should_show = is_visible or has_windows

            local ws_color = space_colors[i] or colors.blue

            -- Update state
            space_states[i] = {
                visible = is_visible,
                has_windows = has_windows,
            }

            -- Set visibility
            space:set({ drawing = should_show })

            if should_show then
                -- Update icons
                update_space_icons(space, i, has_windows_set)

                -- Apply vertical pill style with animation
                sbar.animate("tanh", ANIMATION_DURATION, function()
                    if is_visible then
                        space:set({
                            background = {
                                color = ws_color,
                                height = PILL_HEIGHT_FOCUSED,
                            },
                            icon = { color = colors.crust },
                            label = { color = colors.crust },
                        })
                    else
                        space:set({
                            background = {
                                color = colors.with_alpha(ws_color, 0.3),
                                height = PILL_HEIGHT_UNFOCUSED,
                            },
                            icon = { color = colors.with_alpha(ws_color, 0.6) },
                            label = { color = colors.with_alpha(ws_color, 0.6) },
                        })
                    end
                end)
            end

            ::continue::
        end
    end)
end

-- ============================================================================
-- Create Space Item
-- ============================================================================

local function create_space_item(workspace, label, sync_index)
    local space_name = "space." .. workspace
    local home = os.getenv("HOME")
    local aerospace_config = home .. "/.config/aerospace"

    local ws_color = colors.get_rainbow(tonumber(label) or workspace)
    space_colors[workspace] = ws_color
    space_states[workspace] = { visible = false, has_windows = false }

    local space = sbar.add("item", space_name, {
        position = "left",
        drawing = false,
        padding_left = 4,
        padding_right = 4,
        background = {
            color = colors.with_alpha(ws_color, 0.3),
            corner_radius = 6,
            height = PILL_HEIGHT_UNFOCUSED,
            y_offset = PILL_Y_OFFSET,
            border_width = 0,
            drawing = true,
        },
        icon = {
            string = label,
            drawing = true,
            font = {
                family = settings.font.text,
                style = settings.font.style.semibold,
                size = 12.0,
            },
            color = colors.with_alpha(ws_color, 0.6),
            padding_left = 6,
            padding_right = 6,
            y_offset = 0,
        },
        label = { drawing = false },
        click_script = string.format('bash "%s/scripts/workspace-sync.sh" %d', aerospace_config, sync_index),
    })

    space_items[workspace] = space

    -- Hover animation: mouse entered
    space:subscribe("mouse.entered", function()
        local state = space_states[workspace]
        if not state then return end

        sbar.animate("tanh", ANIMATION_DURATION, function()
            if state.visible then
                space:set({
                    background = { height = PILL_HEIGHT_FOCUSED + 4 },
                    icon = { color = colors.white },
                    label = { color = colors.white },
                })
            else
                space:set({
                    background = {
                        color = colors.with_alpha(ws_color, 0.5),
                        height = PILL_HEIGHT_UNFOCUSED + 20,
                    },
                    icon = { color = ws_color },
                    label = { color = ws_color },
                })
            end
        end)
    end)

    -- Hover animation: mouse exited
    space:subscribe("mouse.exited", function()
        local state = space_states[workspace]
        if not state then return end

        sbar.animate("tanh", ANIMATION_DURATION, function()
            if state.visible then
                space:set({
                    background = {
                        color = ws_color,
                        height = PILL_HEIGHT_FOCUSED,
                    },
                    icon = { color = colors.crust },
                    label = { color = colors.crust },
                })
            else
                space:set({
                    background = {
                        color = colors.with_alpha(ws_color, 0.3),
                        height = PILL_HEIGHT_UNFOCUSED,
                    },
                    icon = { color = colors.with_alpha(ws_color, 0.6) },
                    label = { color = colors.with_alpha(ws_color, 0.6) },
                })
            end
        end)
    end)

    return space
end

-- ============================================================================
-- Initialize
-- ============================================================================

local function init_spaces()
    sbar.exec("command -v aerospace", function(output)
        if not output or output == "" then return end

        -- Create spaces 1-10 (they represent merged N and N+10)
        for i = 1, 10 do
            create_space_item(i, tostring(i), i)
        end

        -- Create global workspace observer
        local workspace_observer = sbar.add("item", "spaces_observer", {
            position = "left",
            drawing = false,
            updates = "on",
            update_freq = 5,
        })

        workspace_observer:subscribe("aerospace_workspace_change", update_all_spaces)
        workspace_observer:subscribe("routine", update_all_spaces)

        -- Initial update
        sbar.exec("sleep 0.5", update_all_spaces)
    end)
end

init_spaces()
