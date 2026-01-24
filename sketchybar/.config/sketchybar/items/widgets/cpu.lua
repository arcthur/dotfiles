-- items/widgets/cpu.lua
-- CPU usage with graph display (using C event provider)

local colors = require("colors")
local settings = require("settings")

-- Register CPU update event (triggered by C event provider)
sbar.add("event", "cpu_update")

-- CPU graph
local cpu_graph = sbar.add("graph", "cpu.graph", 35, {
    position = "right",
    width    = 0,
    padding_right = 0,
    graph = {
        color      = colors.text,
        fill_color = colors.overlay2_50,
    },
    label = { drawing = false },
    icon  = { drawing = false },
    background = {
        height  = 30,
        drawing = false,
        color   = colors.transparent,
    },
})

-- CPU label (top)
local cpu_top = sbar.add("item", "cpu.top", {
    position = "right",
    width    = 0,
    padding_right = 5,
    y_offset = 6,
    label = {
        string = "CPU",
        font = {
            family = settings.font.label,
            style  = settings.font.style.regular,
            size   = 8,
        },
        color = colors.white,
    },
    icon = { drawing = false },
    click_script = "open -a 'Activity Monitor'",
})

-- CPU percentage
local cpu_percent = sbar.add("item", "cpu.percent", {
    position    = "right",
    width       = 40,
    padding_right = 5,
    y_offset    = -4,
    label = {
        font = {
            family = settings.font.label,
            style  = settings.font.style.regular,
            size   = 12,
        },
        color = colors.white,
    },
    icon = { drawing = false },
    click_script = "open -a 'Activity Monitor'",
})

-- CPU spacer
sbar.add("item", "cpu.spacer", {
    position = "right",
    width    = 10,
    background = { drawing = false },
    icon     = { drawing = false },
    label    = { drawing = false },
})

-- Handle CPU update event from C provider
cpu_percent:subscribe("cpu_update", function(env)
    local total = tonumber(env.TOTAL_PERCENT) or 0
    local graph_value = tonumber(env.GRAPH_VALUE) or 0

    -- Color based on usage
    local color
    if total >= 70 then
        color = colors.red
    elseif total >= 30 then
        color = colors.peach
    else
        color = colors.white
    end

    cpu_percent:set({
        label = { string = total .. "%", color = color },
    })

    cpu_graph:push({ graph_value })
end)

-- Fallback: also support routine updates if C provider not running
local function update_cpu_fallback()
    local script = [[
        ps -A -o pcpu= -o user= | awk -v u="$(id -un)" -v cores="$(sysctl -n machdep.cpu.thread_count)" '
            {if ($2==u) user+=$1; else sys+=$1}
            END {
                total = (sys + user) / (100 * cores)
                printf "%.0f %.6f", total * 100, user / (100 * cores)
            }
        '
    ]]

    sbar.exec(script, function(output)
        if not output or output == "" then
            cpu_percent:set({ label = "--" })
            return
        end

        local cpu_pct, cpu_user = output:match("(%d+)%s+([%d%.]+)")
        cpu_pct = tonumber(cpu_pct) or 0
        cpu_user = tonumber(cpu_user) or 0

        local color
        if cpu_pct >= 70 then
            color = colors.red
        elseif cpu_pct >= 30 then
            color = colors.peach
        else
            color = colors.white
        end

        cpu_percent:set({
            label = { string = cpu_pct .. "%", color = color },
        })

        cpu_graph:push({ cpu_user })
    end)
end

-- Subscribe to forced for initial update and fallback
cpu_percent:subscribe("forced", update_cpu_fallback)
