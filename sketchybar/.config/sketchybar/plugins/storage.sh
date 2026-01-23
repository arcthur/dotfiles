#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

# Get disk free percentage (prefer Data volume on macOS)
MOUNT_POINT="/System/Volumes/Data"
if [ ! -d "$MOUNT_POINT" ]; then
  MOUNT_POINT="/"
fi

DISK_USED=$(df -H "$MOUNT_POINT" | awk 'NR==2 {gsub(/%/,""); print $5}')
DISK_FREE=$((100 - DISK_USED))

# Color based on free space (warning when low)
case ${DISK_FREE} in
    [0-9])          COLOR="$RED" ;;       # <10% free - critical
    1[0-9])         COLOR="$PEACH" ;;     # 10-19% free - warning
    2[0-9])         COLOR="$YELLOW" ;;    # 20-29% free - caution
    *)              COLOR="$WHITE" ;;     # 30%+ free - ok
esac

sketchybar --set "$NAME" label="${DISK_FREE}%" label.color="$COLOR" icon.color="$COLOR"
