#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

MP_OUT="$(memory_pressure)"
MEMORY_USAGE=$(grep "System-wide memory free percentage:" <<<"$MP_OUT" | awk '{ printf("%02.0f\n", 100-$5) }')
MEMORY_GRAPH=$(grep "System-wide memory free percentage:" <<<"$MP_OUT" | awk '{ printf("%0.02f\n", (100-$5)/100) }')

COLOR=$WHITE
case "$MEMORY_USAGE" in
  [1-2][0-9]) COLOR=$WHITE
  ;;
  [3-6][0-9]) COLOR=$PEACH
  ;;
  [7-9][0-9]|100) COLOR=$RED
  ;;
esac

sketchybar --set ram.percent label="${MEMORY_USAGE}%" label.color=$COLOR \
           --push ram.graph  ${MEMORY_GRAPH}