-- items/clock.lua
-- Clock and weather display (matches bash clock.sh)

local colors = require("colors")
local settings = require("settings")

-- Weather icons
local weather_icons = {
    day = {
        snow    = "󰼶",
        rain    = "󰖗",
        partly  = "󰖕",
        sunny   = "󰖙",
        cloud   = "󰖐",
        fog     = "󰖑",
        thunder = "󰖓",
    },
    night = {
        snow    = "󰼶",
        rain    = "󰖗",
        clear   = "󰖔",
        cloud   = "󰼱",
        fog     = "󰖑",
        thunder = "󰖓",
    },
}

local LOCATION = os.getenv("WEATHER_LOCATION") or "Singapore"

-- Clock item
local clock = sbar.add("item", "clock", {
    position    = "right",
    update_freq = settings.update.clock,
    icon = {
        string = "󰃰 ",
        font = {
            family = settings.font.text,
            style  = settings.font.style.bold,
            size   = 14.0,
        },
        color = colors.red,
    },
    label = {
        font = {
            family = settings.font.label,
            style  = settings.font.style.regular,
            size   = 13.0,
        },
    },
    click_script = "open -a 'Calendar'",
})

-- Weather/Temp item
local temp = sbar.add("item", "temp", {
    position    = "right",
    update_freq = settings.update.slow,
    icon = {
        font = {
            family = settings.font.text,
            style  = settings.font.style.bold,
            size   = 19.0,
        },
        color = colors.teal,
    },
    label = {
        font = {
            family = settings.font.label,
            style  = settings.font.style.regular,
            size   = 13.0,
        },
    },
    click_script = "open -a Weather",
})

-- Utils bracket (groups clock and temp)
sbar.add("bracket", "utils", { "clock", "temp" }, {
    background = {
        color         = colors.surface0,
        corner_radius = 7,
        height        = 32,
    },
    shadow = false,
})

-- Divider after utils bracket
sbar.add("item", "divider", {
    position = "right",
    width    = 8,
    background = { drawing = false },
    icon     = { drawing = false },
    label    = { drawing = false },
})

-- Update clock
clock:subscribe({ "routine", "forced", "system_woke" }, function()
    clock:set({
        label = os.date("%a %d %I:%M %p"),
    })
end)

-- Get weather icon based on condition
local function get_weather_icon(condition, is_day)
    condition = condition:lower()

    if is_day then
        if condition:find("snow") then
            return weather_icons.day.snow
        elseif condition:find("rain") or condition:find("shower") or condition:find("drizzle") then
            return weather_icons.day.rain
        elseif condition:find("partly") or condition:find("overcast") then
            return weather_icons.day.partly
        elseif condition:find("sunny") or condition:find("clear") then
            return weather_icons.day.sunny
        elseif condition:find("cloud") then
            return weather_icons.day.cloud
        elseif condition:find("haze") or condition:find("mist") or condition:find("fog") then
            return weather_icons.day.fog
        elseif condition:find("thunder") then
            return weather_icons.day.thunder
        else
            return weather_icons.day.sunny
        end
    else
        if condition:find("snow") then
            return weather_icons.night.snow
        elseif condition:find("rain") or condition:find("shower") or condition:find("drizzle") then
            return weather_icons.night.rain
        elseif condition:find("clear") then
            return weather_icons.night.clear
        elseif condition:find("cloud") or condition:find("overcast") or condition:find("partly") then
            return weather_icons.night.cloud
        elseif condition:find("fog") or condition:find("mist") or condition:find("haze") then
            return weather_icons.night.fog
        elseif condition:find("thunder") then
            return weather_icons.night.thunder
        else
            return weather_icons.night.clear
        end
    end
end

-- Update weather
local function update_weather()
    local url = string.format("wttr.in/%s?format=%%t|%%C", LOCATION)

    sbar.exec("curl -fsSL '" .. url .. "' 2>/dev/null", function(output)
        if not output or output == "" or output:find("Unknown") then
            temp:set({
                label = { string = "--" },
                icon  = { string = "󰖐", color = colors.teal },
            })
            return
        end

        -- Remove + sign and parse
        output = output:gsub("%+", "")
        local temperature, condition = output:match("([^|]+)|(.+)")

        if temperature then
            temperature = temperature:gsub("[°C%s]", "")
            local hour = tonumber(os.date("%H"))
            local is_day = hour >= 6 and hour < 18
            local icon = get_weather_icon(condition or "", is_day)

            temp:set({
                label = { string = temperature .. "°C" },
                icon  = { string = icon, color = colors.teal },
            })
        end
    end)
end

temp:subscribe({ "routine", "forced", "system_woke" }, update_weather)
