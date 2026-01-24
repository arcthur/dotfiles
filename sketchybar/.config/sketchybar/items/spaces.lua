-- items/spaces.lua
-- Aerospace workspace integration with multi-monitor support

local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Register aerospace workspace change event
sbar.add("event", "aerospace_workspace_change")

-- Store space items for later reference
local space_items = {}
local bracket_items = {}

-- Get app icon from mapping
local function get_app_icon(app_name)
    return app_icons[app_name] or ":default:"
end

-- Create a space item
local function create_space_item(workspace, label, sync_index)
    local space_name = "space." .. workspace
    local bracket_name = "space_bracket." .. workspace

    local home = os.getenv("HOME")
    local aerospace_config = home .. "/.config/aerospace"

    -- Create space item
    local space = sbar.add("item", space_name, {
        position = "left",
        drawing  = false,
        background = {
            color         = colors.surface0,
            corner_radius = 5,
            height        = 24,
            border_width  = 1,
            border_color  = colors.surface1,
            drawing       = true,
        },
        label = {
            string        = label,
            font = {
                family = settings.font.label,
                style  = settings.font.style.regular,
                size   = 13.0,
            },
            color         = colors.overlay1,
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
            color         = colors.overlay1,
            padding_left  = 6,
            padding_right = 6,
        },
        click_script = string.format('bash "%s/scripts/workspace-sync.sh" %d', aerospace_config, sync_index),
    })

    -- Create bracket for double border effect
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

    return space, bracket
end

-- Update a single space item
function update_space(workspace)
    local space = space_items[workspace]
    local bracket = bracket_items[workspace]

    if not space or not bracket then return end

    -- Get visible workspaces and windows in parallel
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

            -- Show/hide logic
            if is_visible or has_windows then
                space:set({ drawing = true })
                bracket:set({ drawing = true })
            else
                space:set({ drawing = false })
                bracket:set({ drawing = false })
                return
            end

            -- Style based on visibility
            if is_visible then
                sbar.animate("tanh", 20, function()
                    space:set({
                        background = {
                            color        = colors.blue,
                            border_color = colors.sapphire,
                        },
                        label = { color = colors.crust },
                        icon  = { color = colors.crust },
                    })
                    bracket:set({
                        background = { border_color = colors.lavender },
                    })
                end)
            else
                sbar.animate("tanh", 20, function()
                    space:set({
                        background = {
                            color        = colors.surface0,
                            border_color = colors.surface1,
                        },
                        label = { color = colors.overlay1 },
                        icon  = { color = colors.overlay1 },
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
                    -- Parse: ID | App Name | Window Title
                    local app_name = line:match("|%s*([^|]+)%s*|")
                    if app_name then
                        app_name = app_name:match("^%s*(.-)%s*$")  -- trim
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
    -- Check if aerospace is available
    sbar.exec("command -v aerospace", function(output)
        if not output or output == "" then
            return
        end

        -- Get monitor information
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

            -- Delay initial trigger to ensure all items are registered
            sbar.exec("sleep 0.5 && sketchybar --trigger aerospace_workspace_change")
        end)
    end)
end

-- Initialize on load
init_spaces()
