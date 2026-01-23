#!/usr/bin/env bash

source "$HOME/.config/sketchybar/colors.sh"

MEM_FREE=$(memory_pressure | awk '/System-wide memory free percentage:/ {gsub(/%/,""); print $5; exit}')
MEMORY_USAGE=$((100 - MEM_FREE))

case $MEMORY_USAGE in
    [1-2][0-9])     COLOR=$WHITE ;;
    [3-6][0-9])     COLOR=$PEACH ;;
    [7-9][0-9]|100) COLOR=$RED ;;
    *)              COLOR=$WHITE ;;
esac

# Pure bash: 0.XX format
printf -v MEMORY_GRAPH "0.%02d" "$MEMORY_USAGE"

sketchybar --set ram.percent label="${MEMORY_USAGE}%" label.color=$COLOR \
           --push ram.graph "$MEMORY_GRAPH"
