#!/bin/bash

CACHE_FILE="/tmp/sketchybar_network_cache"

have_cmd() { command -v "$1" >/dev/null 2>&1; }

# Auto-detect active network interface
INTERFACE=""
if have_cmd route; then
    INTERFACE=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
fi
if [ -z "$INTERFACE" ] && have_cmd netstat; then
    INTERFACE=$(netstat -ibn 2>/dev/null | awk '$1 !~ /^lo0$/ && /Link/ {print $1; exit}')
fi
[ -z "$INTERFACE" ] && INTERFACE="en0"

# --- WiFi Status (only if items exist and deps available) ---
if sketchybar --query wifi >/dev/null 2>&1 && have_cmd networksetup && have_cmd ipconfig; then
    WIFI_DEV=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
    SSID=$(ipconfig getsummary "$WIFI_DEV" 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2}')

    if [ -n "$SSID" ]; then
        sketchybar --set wifi label="$SSID" \
                   --set wifiPopup icon="󰖩" icon.color=0xff94e2d5
    else
        sketchybar --set wifi label="N/A" \
                   --set wifiPopup icon="󰤭" icon.color=0xfff38ba8
    fi
fi

# --- Network Speed ---
if ! have_cmd netstat; then
    sketchybar --set net.down label="--" \
               --set net.up label="--"
    exit 0
fi

read -r rx tx <<< "$(netstat -ibn | awk -v iface="$INTERFACE" '$1 == iface && /Link/ {print $7, $10; exit}')"
now=$(date +%s)

[ -z "$rx" ] && rx=0
[ -z "$tx" ] && tx=0

if [ -f "$CACHE_FILE" ]; then
    read -r prev_time prev_rx prev_tx < "$CACHE_FILE"
else
    prev_time=$now prev_rx=$rx prev_tx=$tx
fi

echo "$now $rx $tx" > "$CACHE_FILE"

elapsed=$((now - prev_time))
[ "$elapsed" -le 0 ] && elapsed=1

DOWN=$(( (rx - prev_rx) / elapsed ))
UP=$(( (tx - prev_tx) / elapsed ))

[ "$DOWN" -lt 0 ] && DOWN=0
[ "$UP" -lt 0 ] && UP=0

human_readable() {
    local bytes=$1
    if [ "$bytes" -ge 1048576 ]; then
        awk -v b="$bytes" 'BEGIN { printf "%.1f MB/s", b/1048576 }'
    elif [ "$bytes" -ge 1024 ]; then
        awk -v b="$bytes" 'BEGIN { printf "%.0f KB/s", b/1024 }'
    else
        printf "%d B/s" "$bytes"
    fi
}

sketchybar --set net.down label="$(human_readable $DOWN)" \
           --set net.up label="$(human_readable $UP)"
