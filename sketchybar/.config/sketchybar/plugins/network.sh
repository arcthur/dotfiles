#!/usr/bin/env bash

source "$HOME/.config/sketchybar/colors.sh"
CACHE_FILE="/tmp/sketchybar_network_cache"

# Auto-detect active network interface
INTERFACE=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
[[ -z $INTERFACE ]] && INTERFACE=$(netstat -ibn 2>/dev/null | awk '$1 !~ /^lo0$/ && /Link/ {print $1; exit}')
: "${INTERFACE:=en0}"

# --- WiFi Status (only if wifi item exists) ---
if sketchybar --query wifi >/dev/null 2>&1 && command -v ipconfig >/dev/null 2>&1; then
    WIFI_DEV=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
    CONNECTED=$(ipconfig getsummary "$WIFI_DEV" 2>/dev/null | awk '/State : BOUND/ {print 1; exit}')

    if [[ -n $CONNECTED ]]; then
        sketchybar --set wifi icon="󰖩" icon.color=$TEAL
    else
        sketchybar --set wifi icon="󰤭" icon.color=$RED
    fi
fi

# Network Speed
command -v netstat &>/dev/null || { sketchybar --set net.down label="--" --set net.up label="--"; exit 0; }

read -r rx tx <<< "$(netstat -ibn | awk -v iface="$INTERFACE" '$1 == iface && /Link/ {print $7, $10; exit}')"
now=$(date +%s)
: "${rx:=0}" "${tx:=0}"

if [[ -f $CACHE_FILE ]]; then
    read -r prev_time prev_rx prev_tx < "$CACHE_FILE"
else
    prev_time=$now prev_rx=$rx prev_tx=$tx
fi

printf '%s %s %s\n' "$now" "$rx" "$tx" > "$CACHE_FILE"

elapsed=$((now - prev_time))
((elapsed <= 0)) && elapsed=1

DOWN=$(( (rx - prev_rx) / elapsed ))
UP=$(( (tx - prev_tx) / elapsed ))
((DOWN < 0)) && DOWN=0
((UP < 0)) && UP=0

human() {
    local b=$1
    if ((b >= 1048576)); then
        printf "%d.%d MB/s" "$((b / 1048576))" "$(((b % 1048576) * 10 / 1048576))"
    elif ((b >= 1024)); then
        printf "%d KB/s" "$((b / 1024))"
    else
        printf "%d B/s" "$b"
    fi
}

sketchybar --set net.down label="$(human $DOWN)" --set net.up label="$(human $UP)"
