-- icons.lua
-- Icon definitions (SF Symbols and Nerd Font)

local settings = require("settings")

local icons = {
    -- SF Symbols (used when settings.icons == "sf-symbols")
    sf = {
        loading     = "􀖇",
        apple       = "􀣺",
        preferences = "􀺽",
        activity    = "􀒓",
        lock        = "􀒳",
        bell        = "􀋚",
        bell_dot    = "􀝗",
        -- Battery
        battery = {
            _100     = "􀛨",
            _75      = "􀺸",
            _50      = "􀺶",
            _25      = "􀛩",
            _0       = "􀛪",
            charging = "􀢋",
        },
        -- Volume
        volume = {
            _100 = "􀊩",
            _66  = "􀊧",
            _33  = "􀊥",
            _10  = "􀊡",
            _0   = "􀊣",
        },
        -- Switch
        switch = {
            on  = "􀯶",
            off = "􀯷",
        },
    },

    -- Nerd Font icons (used when settings.icons == "nerdfont")
    nerd = {
        loading     = "",
        apple       = "",
        preferences = "",
        activity    = "",
        lock        = "󰌾",
        bell        = "󰂚",
        bell_dot    = "󰂞",
        clock       = "󰃰",
        wifi        = "󰖩",
        wifi_off    = "󰤭",
        storage     = "󰋊",
        -- Battery (discharging)
        battery = {
            _100 = "󰁹",
            _90  = "󰂂",
            _80  = "󰂁",
            _70  = "󰂀",
            _60  = "󰁿",
            _50  = "󰁾",
            _40  = "󰁽",
            _30  = "󰁼",
            _20  = "󰁻",
            _10  = "󰁺",
            _0   = "󰂎",
        },
        -- Battery (charging)
        battery_charging = {
            _100 = "󰂄",
            _90  = "󰂋",
            _80  = "󰂊",
            _70  = "󰢞",
            _60  = "󰂉",
            _50  = "󰢝",
            _40  = "󰂈",
            _30  = "󰂇",
            _20  = "󰂆",
            _10  = "󰢜",
        },
        -- Weather
        weather = {
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
        },
        -- Network
        net = {
            up   = "⇡",
            down = "⇣",
        },
    },
}

-- Return the appropriate icon set based on settings
if settings.icons == "sf-symbols" then
    return icons.sf
else
    return icons.nerd
end
