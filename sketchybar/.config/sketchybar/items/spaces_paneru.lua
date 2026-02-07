-- items/spaces_paneru.lua
-- macOS native space indicators for paneru (scrolling tiling WM)
-- Uses sketchybar's built-in space component to track Mission Control spaces

local colors = require("colors")
local settings = require("settings")

-- ============================================================================
-- Style Constants (matching aerospace version for visual consistency)
-- ============================================================================

local PILL_HEIGHT_UNFOCUSED = 6
local PILL_HEIGHT_FOCUSED = 64
local PILL_Y_OFFSET = 20
local ANIMATION_DURATION = 10
local MAX_SPACES = 10

local space_items = {}
local space_colors = {}
local space_states = {}

-- ============================================================================
-- Create Space Items
-- ============================================================================

for i = 1, MAX_SPACES do
    local ws_color = colors.get_rainbow(i)
    space_colors[i] = ws_color
    space_states[i] = { selected = false, has_windows = false }

    local space = sbar.add("space", "space." .. i, {
        space = i,
        position = "left",
        padding_left = 4,
        padding_right = 4,
        drawing = false,
        background = {
            color = colors.with_alpha(ws_color, 0.3),
            corner_radius = 6,
            height = PILL_HEIGHT_UNFOCUSED,
            y_offset = PILL_Y_OFFSET,
            border_width = 0,
            drawing = true,
        },
        icon = {
            string = tostring(i),
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
    })

    space_items[i] = space

    -- ========================================================================
    -- Space Change: highlight active space
    -- ========================================================================

    space:subscribe("space_change", function(env)
        local selected = env.SELECTED == "true"
        space_states[i].selected = selected

        local should_show = selected or space_states[i].has_windows
        space:set({ drawing = should_show })

        if not should_show then return end

        sbar.animate("tanh", ANIMATION_DURATION, function()
            if selected then
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

    -- ========================================================================
    -- Window Change: show/hide spaces that have windows (macOS 14+)
    -- ========================================================================

    space:subscribe("space_windows_change", function(env)
        local info = env.INFO or ""
        local has_windows = info ~= "" and info ~= "[]"
        space_states[i].has_windows = has_windows

        local should_show = space_states[i].selected or has_windows
        space:set({ drawing = should_show })

        if should_show and not space_states[i].selected then
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

    -- ========================================================================
    -- Hover Animations
    -- ========================================================================

    space:subscribe("mouse.entered", function()
        local state = space_states[i]
        if not state or not state.selected and not state.has_windows then return end

        sbar.animate("tanh", ANIMATION_DURATION, function()
            if state.selected then
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

    space:subscribe("mouse.exited", function()
        local state = space_states[i]
        if not state or not state.selected and not state.has_windows then return end

        sbar.animate("tanh", ANIMATION_DURATION, function()
            if state.selected then
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
end
