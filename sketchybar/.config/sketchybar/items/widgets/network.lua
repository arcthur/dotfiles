-- items/widgets/network.lua
-- Network speed display with upload/download rates (using C event provider)

local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

local SIZE = 11
local WIDTH = 70
local CACHE_FILE = settings.cache_dir .. "/sketchybar_network_cache"

-- Register network update event (triggered by C event provider)
sbar.add("event", "network_update")

-- Upload speed item
local net_up = sbar.add("item", "net.up", {
    position    = "right",
    width       = 0,
    y_offset    = 5,
    icon = {
        string = icons.net.up,
        font = { size = SIZE },
        color = colors.peach,
    },
    label = {
        width = WIDTH,
        align = "right",
        font  = { size = SIZE },
    },
})

-- Download speed item
local net_down = sbar.add("item", "net.down", {
    position = "right",
    y_offset = -5,
    icon = {
        string = icons.net.down,
        font = { size = SIZE },
        color = colors.sapphire,
    },
    label = {
        width = WIDTH,
        align = "right",
        font  = { size = SIZE },
    },
})

-- Network bracket (includes wifi)
sbar.add("bracket", "network", { "wifi", "net.up", "net.down" }, {
    background = {
        color         = colors.surface0,
        corner_radius = 7,
        height        = 32,
    },
    shadow = false,
})

-- Divider after network bracket
sbar.add("item", "net.divider", {
    position = "right",
    width    = 8,
    background = { drawing = false },
    icon     = { drawing = false },
    label    = { drawing = false },
})

-- Handle network update event from C provider
net_up:subscribe("network_update", function(env)
    local speed_down_str = env.SPEED_DOWN_STR or "0 B/s"
    local speed_up_str = env.SPEED_UP_STR or "0 B/s"

    net_down:set({ label = speed_down_str })
    net_up:set({ label = speed_up_str })
end)

-- Format bytes to human readable
local function human_readable(bytes)
    if bytes >= 1048576 then
        return string.format("%.1f MB/s", bytes / 1048576)
    elseif bytes >= 1024 then
        return string.format("%d KB/s", math.floor(bytes / 1024))
    else
        return string.format("%d B/s", bytes)
    end
end

-- Fallback: shell-based update if C provider not running
local function update_network_fallback()
    local script = [[
        INTERFACE=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
        [ -z "$INTERFACE" ] && INTERFACE=$(netstat -ibn 2>/dev/null | awk '$1 !~ /^lo0$/ && /Link/ {print $1; exit}')
        : "${INTERFACE:=en0}"

        # WiFi status
        if command -v ipconfig >/dev/null 2>&1; then
            WIFI_DEV=$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi/{getline; print $2}')
            CONNECTED=$(ipconfig getsummary "$WIFI_DEV" 2>/dev/null | awk '/State : BOUND/ {print 1; exit}')
            echo "WIFI:${CONNECTED:-0}"
        fi

        # Network bytes
        read -r rx tx <<< "$(netstat -ibn 2>/dev/null | awk -v iface="$INTERFACE" '$1 == iface && /Link/ {print $7, $10; exit}')"
        echo "RX:${rx:-0}"
        echo "TX:${tx:-0}"
        echo "TIME:$(date +%s)"
    ]]

    sbar.exec(script, function(output)
        if not output or output == "" then
            net_up:set({ label = "--" })
            net_down:set({ label = "--" })
            return
        end

        -- Parse output
        local wifi_connected = output:match("WIFI:(%d)")
        local rx = tonumber(output:match("RX:(%d+)")) or 0
        local tx = tonumber(output:match("TX:(%d+)")) or 0
        local now = tonumber(output:match("TIME:(%d+)")) or os.time()

        -- Update WiFi icon
        if wifi_connected == "1" then
            sbar.set("wifi", {
                icon = { string = icons.wifi, color = colors.teal }
            })
        else
            sbar.set("wifi", {
                icon = { string = icons.wifi_off, color = colors.red }
            })
        end

        -- Read previous values from cache
        local prev_time, prev_rx, prev_tx = now, rx, tx
        local cache_file = io.open(CACHE_FILE, "r")
        if cache_file then
            local line = cache_file:read("*l")  -- Compatible with Lua 5.3+
            if line then
                prev_time, prev_rx, prev_tx = line:match("(%d+) (%d+) (%d+)")
                prev_time = tonumber(prev_time) or now
                prev_rx = tonumber(prev_rx) or rx
                prev_tx = tonumber(prev_tx) or tx
            end
            cache_file:close()
        end

        -- Write current values to cache
        cache_file = io.open(CACHE_FILE, "w")
        if cache_file then
            cache_file:write(string.format("%d %d %d", now, rx, tx))
            cache_file:close()
        end

        -- Calculate speeds
        local elapsed = now - prev_time
        if elapsed <= 0 then elapsed = 1 end

        local down_speed = math.max(0, math.floor((rx - prev_rx) / elapsed))
        local up_speed = math.max(0, math.floor((tx - prev_tx) / elapsed))

        net_down:set({ label = human_readable(down_speed) })
        net_up:set({ label = human_readable(up_speed) })
    end)
end

-- Subscribe to forced and system_woke for fallback
net_up:subscribe({ "forced", "system_woke" }, update_network_fallback)
