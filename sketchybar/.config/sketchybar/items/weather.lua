-- items/weather.lua
-- Multi-city weather display with wttr.in API

local colors = require("colors")
local settings = require("settings")

-- ============================================================================
-- Configuration
-- ============================================================================

local LOCATIONS = { "SH", "SG", "BJ" }  -- Cities to display (left to right)
local TIMEOUT = 5

-- City abbreviation -> full name for wttr.in query
local city_map = {
    SH = "Shanghai",
    SG = "Singapore",
    BJ = "Beijing",
}

-- Weather condition patterns -> icon (day, night)
local weather_patterns = {
    { pattern = "snow",                          day = "󰼶", night = "󰼶" },
    { pattern = "rain|shower|drizzle",           day = "󰖗", night = "󰖗" },
    { pattern = "thunder",                       day = "󰖓", night = "󰖓" },
    { pattern = "fog|mist|haze",                 day = "󰖑", night = "󰖑" },
    { pattern = "partly|overcast",               day = "󰖕", night = "󰼱" },
    { pattern = "cloud",                         day = "󰖐", night = "󰼱" },
    { pattern = "sunny|clear",                   day = "󰖙", night = "󰖔" },
}
local default_icons = { day = "󰖙", night = "󰖔" }

-- ============================================================================
-- Helper Functions
-- ============================================================================

local function url_encode(str)
    if not str then return "" end
    return str:gsub("([^%w%-%.%_%~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
end

local function get_weather_icon(condition, is_day)
    condition = (condition or ""):lower()
    for _, entry in ipairs(weather_patterns) do
        if condition:find(entry.pattern) then
            return is_day and entry.day or entry.night
        end
    end
    return is_day and default_icons.day or default_icons.night
end

-- ============================================================================
-- Create Weather Items
-- ============================================================================

local weather_items = {}
local item_names = {}

local function create_weather_item(abbr, index)
    local item_name = "weather." .. abbr:lower()
    table.insert(item_names, item_name)

    local item = sbar.add("item", item_name, {
        position    = "right",
        update_freq = settings.update.slow,
        icon = {
            string = "󰖐",
            font = {
                family = settings.font.text,
                style  = settings.font.style.bold,
                size   = 16.0,
            },
            color = colors.teal,
            padding_left = (index == 1) and 2 or 4,
        },
        label = {
            string = abbr .. " --",
            font = {
                family = settings.font.label,
                style  = settings.font.style.regular,
                size   = 12.0,
            },
        },
        click_script = "open -a Weather",
    })

    weather_items[abbr] = item

    -- Divider between cities (not before the leftmost)
    if index > 1 then
        sbar.add("item", item_name .. ".divider", {
            position = "right",
            width    = 4,
            background = { drawing = false },
            icon     = { drawing = false },
            label    = { drawing = false },
        })
        table.insert(item_names, item_name .. ".divider")
    end

    return item
end

-- Create items in reverse order (position="right" adds from right to left)
for i = #LOCATIONS, 1, -1 do
    create_weather_item(LOCATIONS[i], i)
end

-- Bracket background
sbar.add("bracket", "weather", item_names, {
    background = {
        color         = colors.surface0,
        corner_radius = 7,
        height        = 32,
    },
    shadow = false,
})

-- Divider after bracket
sbar.add("item", "weather.divider", {
    position = "right",
    width    = 8,
    background = { drawing = false },
    icon     = { drawing = false },
    label    = { drawing = false },
})

-- ============================================================================
-- Update Logic
-- ============================================================================

local function update_city_weather(abbr)
    local item = weather_items[abbr]
    if not item then return end

    local city = city_map[abbr:upper()] or abbr
    local cmd = string.format(
        "curl -fsSL -m %d 'wttr.in/%s?format=%%t|%%C' 2>/dev/null",
        TIMEOUT, url_encode(city)
    )

    sbar.exec(cmd, function(output)
        if not output or output == "" or output:find("Unknown") or output:find("ERROR") then
            item:set({
                label = { string = abbr .. " --" },
                icon  = { string = "󰖐", color = colors.teal },
            })
            return
        end

        local temp, condition = output:gsub("%+", ""):match("([^|]+)|(.+)")
        if temp then
            temp = temp:gsub("[°C%s]", "")
            local is_day = tonumber(os.date("%H")) >= 6 and tonumber(os.date("%H")) < 18
            item:set({
                label = { string = abbr .. " " .. temp .. "°" },
                icon  = { string = get_weather_icon(condition, is_day), color = colors.teal },
            })
        end
    end)
end

local function update_all_weather()
    for _, abbr in ipairs(LOCATIONS) do
        update_city_weather(abbr)
    end
end

-- Subscribe and initial update
local first_item = weather_items[LOCATIONS[1]]
if first_item then
    first_item:subscribe({ "routine", "forced", "system_woke" }, update_all_weather)
end

sbar.exec("true", update_all_weather)
