-- items/spaces.lua
-- Aerospace workspace integration with vertical pill style (BenjaminBini inspired)
-- Supports cross-monitor workspace merging: workspace N and N+10 are displayed as one item

local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local SHELL_PATH = settings.shell_path or "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin"

-- Register aerospace workspace change event
sbar.add("event", "aerospace_workspace_change")
-- Event for window open/move reconciliation (no workspace payload required)
sbar.add("event", "aerospace_windows_changed")

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
-- Bulk Update: Update all workspaces in one efficient operation
-- ============================================================================

local update_inflight = false
local update_pending = false

local function update_all_spaces()
    if update_inflight then
        update_pending = true
        return
    end
    update_inflight = true

    local cmd = [[
        PATH=]] .. SHELL_PATH .. [[:$PATH
        visible=$(aerospace list-workspaces --monitor all --visible 2>/dev/null | tr '\n' ' ')
        echo "VISIBLE:$visible"
        aerospace list-windows --all --format 'WIN:%{workspace}\t%{app-name}' 2>/dev/null
    ]]

    sbar.exec(cmd, function(output)
        update_inflight = false
        if not output then
            if update_pending then
                update_pending = false
                update_all_spaces()
            end
            return
        end

        -- Parse visible workspaces
        local visible_set = {}
        local visible_line = output:match("VISIBLE:([^\n]*)")
        if visible_line then
            for ws in visible_line:gmatch("%S+") do
                visible_set[ws] = true
            end
        end

        local has_windows_set = {}
        local workspace_icons = {}

        local function add_icon(workspace, icon)
            local entry = workspace_icons[workspace]
            if not entry then
                entry = { list = {}, seen = {} }
                workspace_icons[workspace] = entry
            end
            if not entry.seen[icon] then
                entry.seen[icon] = true
                table.insert(entry.list, icon)
            end
        end

        for workspace, app_name in output:gmatch("WIN:([^\t]+)\t([^\n]+)") do
            workspace = workspace:match("^%s*(.-)%s*$")
            app_name = app_name:match("^%s*(.-)%s*$")

            if workspace ~= "" and app_name ~= "" and workspace:match("^%d+$") then
                has_windows_set[workspace] = true
                local icon = app_icons[app_name] or ":default:"
                add_icon(workspace, icon)
            end
        end

        -- Sort icons alphabetically for consistent display across updates
        for _, entry in pairs(workspace_icons) do
            table.sort(entry.list)
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

            local prev_state = space_states[i] or {}
            local prev_visible = (prev_state.visible and true) or false
            local prev_should_show = (prev_state.should_show and true) or false
            local style_changed = prev_visible ~= is_visible or prev_should_show ~= should_show

            local merged_icons = {}
            local merged_seen = {}

            local function merge_workspace_icons(workspace)
                local entry = workspace_icons[workspace]
                if not entry then return end
                for _, icon in ipairs(entry.list) do
                    if not merged_seen[icon] then
                        merged_seen[icon] = true
                        table.insert(merged_icons, icon)
                    end
                end
            end

            if should_show and has_windows then
                merge_workspace_icons(ws_primary)
                merge_workspace_icons(ws_secondary)
            end

            local icons_string = table.concat(merged_icons, " ")
            local prev_icons_string = prev_state.icons_string or ""
            local content_changed = prev_should_show ~= should_show or prev_icons_string ~= icons_string

            -- Update state (keep size bounded; avoid leaking old state tables)
            space_states[i] = {
                visible = is_visible,
                has_windows = has_windows,
                should_show = should_show,
                icons_string = icons_string,
            }

            if prev_should_show ~= should_show then
                space:set({ drawing = should_show })
            end

            if should_show then
                if content_changed then
                    local label_cfg = { drawing = false }
                    if icons_string ~= "" then
                        label_cfg = {
                            drawing = true,
                            string = icons_string,
                            font = "sketchybar-app-font:Regular:13.0",
                            padding_left = 4,
                            padding_right = 6,
                        }
                    end

                    space:set({
                        icon = {
                            string = tostring(i),
                            font = {
                                family = settings.font.label,
                                style = settings.font.style.regular,
                                size = 13.0,
                            },
                        },
                        label = label_cfg,
                    })
                end

                if style_changed then
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
            end

            ::continue::
        end

        if update_pending then
            update_pending = false
            update_all_spaces()
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
    space_states[workspace] = { visible = false, has_windows = false, should_show = false }

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
        click_script = string.format('/bin/bash "%s/scripts/workspace-sync.sh" %d', aerospace_config, sync_index),
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
    sbar.exec("PATH=" .. SHELL_PATH .. " command -v aerospace 2>/dev/null", function(output)
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
        workspace_observer:subscribe("aerospace_windows_changed", update_all_spaces)
        workspace_observer:subscribe("routine", update_all_spaces)

        -- Initial update
        sbar.exec("sleep 0.5", update_all_spaces)
    end)
end

init_spaces()
