-- items/weather.lua
-- Weather display with wttr.in API

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
local TIMEOUT = 5  -- curl timeout in seconds

-- URL encode a string (handle spaces and special characters)
local function url_encode(str)
    if not str then return "" end
    str = str:gsub("([^%w%-%.%_%~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    return str
end

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
    local encoded_location = url_encode(LOCATION)
    local url = string.format("wttr.in/%s?format=%%t|%%C", encoded_location)

    -- Use timeout to prevent blocking, -m for max time
    local cmd = string.format("curl -fsSL -m %d '%s' 2>/dev/null", TIMEOUT, url)
    sbar.exec(cmd, function(output)
        if not output or output == "" or output:find("Unknown") or output:find("ERROR") then
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
