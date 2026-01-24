-- items/weather.lua
-- Weather display using wttr.in

local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

local LOCATION = os.getenv("WEATHER_LOCATION") or "Singapore"

-- Weather item
local weather = sbar.add("item", "temp", {
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

-- Bracket for clock and weather
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

-- Get weather icon based on condition
local function get_weather_icon(condition, is_day)
    condition = condition:lower()

    if is_day then
        if condition:find("snow") then
            return icons.weather.day.snow
        elseif condition:find("rain") or condition:find("shower") or condition:find("drizzle") then
            return icons.weather.day.rain
        elseif condition:find("partly") or condition:find("overcast") then
            return icons.weather.day.partly
        elseif condition:find("sunny") or condition:find("clear") then
            return icons.weather.day.sunny
        elseif condition:find("cloud") then
            return icons.weather.day.cloud
        elseif condition:find("haze") or condition:find("mist") or condition:find("fog") then
            return icons.weather.day.fog
        elseif condition:find("thunder") then
            return icons.weather.day.thunder
        else
            return icons.weather.day.sunny
        end
    else
        if condition:find("snow") then
            return icons.weather.night.snow
        elseif condition:find("rain") or condition:find("shower") or condition:find("drizzle") then
            return icons.weather.night.rain
        elseif condition:find("clear") then
            return icons.weather.night.clear
        elseif condition:find("cloud") or condition:find("overcast") or condition:find("partly") then
            return icons.weather.night.cloud
        elseif condition:find("fog") or condition:find("mist") or condition:find("haze") then
            return icons.weather.night.fog
        elseif condition:find("thunder") then
            return icons.weather.night.thunder
        else
            return icons.weather.night.clear
        end
    end
end

-- Update weather
local function update_weather()
    local url = string.format("wttr.in/%s?format=%%t|%%C", LOCATION)

    sbar.exec("curl -fsSL '" .. url .. "' 2>/dev/null", function(output)
        if not output or output == "" or output:find("Unknown") then
            weather:set({
                label = { string = "--" },
                icon  = { string = icons.weather.day.cloud, color = colors.teal },
            })
            return
        end

        -- Remove + sign and parse
        output = output:gsub("%+", "")
        local temp, condition = output:match("([^|]+)|(.+)")

        if temp then
            temp = temp:gsub("[°C%s]", "")
            local hour = tonumber(os.date("%H"))
            local is_day = hour >= 6 and hour < 18
            local icon = get_weather_icon(condition or "", is_day)

            weather:set({
                label = { string = temp .. "°C" },
                icon  = { string = icon, color = colors.teal },
            })
        end
    end)
end

weather:subscribe({ "routine", "forced", "system_woke" }, update_weather)
