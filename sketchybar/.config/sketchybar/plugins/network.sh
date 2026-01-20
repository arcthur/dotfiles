#!/bin/bash

CACHE_FILE="/tmp/sketchybar_network_cache"

# Auto-detect active network interface
INTERFACE=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
[ -z "$INTERFACE" ] && INTERFACE="en0"

# --- WiFi Status ---
WIFI_DEV=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
SSID=$(ipconfig getsummary "$WIFI_DEV" 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2}')

if [ -n "$SSID" ]; then
    sketchybar --set wifi label="$SSID" \
               --set wifiPopup icon="󰖩" icon.color=0xff94e2d5
else
    sketchybar --set wifi label="N/A" \
               --set wifiPopup icon="󰤭" icon.color=0xfff38ba8
fi

# --- Network Speed ---
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
        printf "%.1f MB/s" "$(echo "scale=1; $bytes/1048576" | bc)"
    elif [ "$bytes" -ge 1024 ]; then
        printf "%.0f KB/s" "$(echo "scale=0; $bytes/1024" | bc)"
    else
        printf "%d B/s" "$bytes"
    fi
}

sketchybar --set net.down label="$(human_readable $DOWN)" \
           --set net.up label="$(human_readable $UP)"
