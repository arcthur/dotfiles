-- items/widgets/battery.lua
-- Battery status with charging indicator

local colors = require("colors")
local settings = require("settings")

-- Battery item
local battery = sbar.add("item", "battery", {
    position    = "right",
    update_freq = settings.update.medium,
    icon = {
        font = {
            family = settings.font.text,
            style  = settings.font.style.bold,
            size   = 18.0,
        },
    },
    click_script = "open 'x-apple.systempreferences:com.apple.Battery-Settings.extension'",
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

-- Update battery status
local function update_battery()
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

battery:subscribe({ "routine", "forced", "system_woke", "power_source_change" }, update_battery)
