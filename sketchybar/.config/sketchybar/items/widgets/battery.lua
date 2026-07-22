-- items/widgets/battery.lua
-- Battery status with charging indicator (using C event provider)

local colors = require("colors")
local settings = require("settings")
local popup = require("helpers.popup")

-- Register battery update event (triggered by C event provider)
sbar.add("event", "battery_update")

-- Battery item
local battery = sbar.add("item", "battery", {
    position = "right",
    icon = {
        font = {
            family = settings.font.text,
            style  = settings.font.style.bold,
            size   = 18.0,
        },
    },
    popup = { align = "center" },
    click_script = "open 'x-apple.systempreferences:com.apple.Battery-Settings.extension'",
})

-- Battery bracket (background box)
sbar.add("bracket", "battery_bracket", { "battery" }, {
    background = {
        color         = colors.surface0,
        corner_radius = 7,
        height        = 32,
    },
    shadow = false,
})

-- Divider after battery bracket
sbar.add("item", "battery.divider", {
    position = "right",
    width    = 8,
    background = { drawing = false },
    icon     = { drawing = false },
    label    = { drawing = false },
})

-- Get battery icon and color based on percentage and charging state
local function get_battery_display(percent, charging)
    local icon, color

    if charging then
        -- Charging icons
        if percent >= 90 then
            icon, color = "󰂋", colors.green
        elseif percent >= 80 then
            icon, color = "󰂊", colors.green
        elseif percent >= 70 then
            icon, color = "󰢞", colors.green
        elseif percent >= 60 then
            icon, color = "󰂉", colors.yellow
        elseif percent >= 50 then
            icon, color = "󰢝", colors.yellow
        elseif percent >= 40 then
            icon, color = "󰂈", colors.peach
        elseif percent >= 30 then
            icon, color = "󰂇", colors.peach
        elseif percent >= 20 then
            icon, color = "󰂆", colors.red
        else
            icon, color = "󰢜", colors.red
        end
    else
        -- Discharging icons
        if percent == 100 then
            icon, color = "󰁹", colors.green
        elseif percent >= 90 then
            icon, color = "󰂂", colors.green
        elseif percent >= 80 then
            icon, color = "󰂁", colors.green
        elseif percent >= 70 then
            icon, color = "󰂀", colors.green
        elseif percent >= 60 then
            icon, color = "󰁿", colors.yellow
        elseif percent >= 50 then
            icon, color = "󰁾", colors.yellow
        elseif percent >= 40 then
            icon, color = "󰁽", colors.peach
        elseif percent >= 30 then
            icon, color = "󰁼", colors.peach
        elseif percent >= 20 then
            icon, color = "󰁻", colors.red
        elseif percent >= 10 then
            icon, color = "󰁺", colors.red
        else
            icon, color = "󰂎", colors.red
        end
    end

    return icon, color
end

-- Handle battery update event from C provider
battery:subscribe("battery_update", function(env)
    local percent = tonumber(env.PERCENT) or 0
    local charging = env.CHARGING == "1"
    local has_battery = env.HAS_BATTERY == "1"

    if not has_battery then
        battery:set({
            icon  = { string = "󰚥", color = colors.green },  -- Plugged in, no battery
            label = { string = "AC" },
        })
        return
    end

    local icon, color = get_battery_display(percent, charging)

    battery:set({
        icon  = { string = icon, color = color },
        label = { string = percent .. "%", color = color },
    })
end)

-- Fallback: shell-based update if C provider not running
local function update_battery_fallback()
    sbar.exec("pmset -g batt", function(output)
        if not output or output == "" then
            battery:set({
                icon  = { string = "󰂑", color = colors.overlay2 },
                label = { string = "--" },
            })
            return
        end

        -- Parse battery percentage
        local percent = tonumber(output:match("(%d+)%%"))
        local charging = output:find("AC Power") ~= nil

        if not percent then
            battery:set({
                icon  = { string = "󰂑", color = colors.overlay2 },
                label = { string = "--" },
            })
            return
        end

        local icon, color = get_battery_display(percent, charging)

        battery:set({
            icon  = { string = icon, color = color },
            label = { string = percent .. "%", color = color },
        })
    end)
end

-- Subscribe to forced and power events for fallback
battery:subscribe({ "forced", "system_woke", "power_source_change" }, update_battery_fallback)

-- ============================================================================
-- Popup: charging state + battery health (shown on hover)
-- ============================================================================

local popup_font = {
    family = settings.font.label,
    style  = settings.font.style.regular,
    size   = 12.0,
}

local popup_status = sbar.add("item", "battery.popup.status", {
    position = "popup.battery",
    icon  = { string = "󱐋", font = { family = settings.font.text, style = settings.font.style.bold, size = 13.0 }, color = colors.peach, padding_left = 8, padding_right = 6 },
    label = { string = "…", font = popup_font, color = colors.text, padding_right = 8 },
})

local popup_health = sbar.add("item", "battery.popup.health", {
    position = "popup.battery",
    icon  = { string = "󰗐", font = { family = settings.font.text, style = settings.font.style.bold, size = 13.0 }, color = colors.green, padding_left = 8, padding_right = 6 },
    label = { string = "…", font = popup_font, color = colors.text, padding_right = 8 },
})

local function capitalize(s)
    if not s or s == "" then return s end
    return s:sub(1, 1):upper() .. s:sub(2)
end

local function update_battery_popup()
    -- pmset gives live state + time estimate; system_profiler gives slow-changing
    -- health data. Both are cheap enough to run on demand (hover).
    local cmd = [[
        pmset -g batt | sed -n '2p'
        echo "---"
        system_profiler SPPowerDataType 2>/dev/null | grep -E 'Cycle Count|Condition|Maximum Capacity'
    ]]
    sbar.exec(cmd, function(out)
        out = out or ""
        local batt_line = out:match("(.-)\n%-%-%-") or out
        local state = batt_line:match(";%s*([%a%s]-);")
        local time  = batt_line:match("(%d+:%d+)%s*remaining")

        local status_str
        if state and state:find("charg") and not state:find("dis") then
            status_str = time and ("Charging · " .. time .. " to full") or "Charging"
        elseif state and state:find("discharg") then
            status_str = time and ("On battery · " .. time .. " left") or "On battery"
        else
            status_str = capitalize(state) or "Plugged in"
        end

        local cycles    = out:match("Cycle Count:%s*(%d+)")
        local condition = out:match("Condition:%s*(%w+)")
        local maxcap    = out:match("Maximum Capacity:%s*(%d+%%)")
        local health_str = string.format(
            "Health %s · %s cycles · %s",
            maxcap or "?", cycles or "?", condition or "Normal"
        )

        popup_status:set({ label = { string = status_str } })
        popup_health:set({ label = { string = health_str } })
    end)
end

popup.hover(battery, update_battery_popup)
