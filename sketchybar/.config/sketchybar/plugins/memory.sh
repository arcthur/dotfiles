#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

MEMORY_USAGE=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ printf("%02.0f\n", 100-$5"%") }')
MEMORY_GRAPH=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ printf("%0.02f\n", (100-$5)/100"%") }')

COLOR=$ACTUAL_WHITE
case "$MEMORY_USAGE" in
  [1-2][0-9]) COLOR=$ACTUAL_WHITE
  ;;
  [3-6][0-9]) COLOR=$ORANGE
  ;;
  [7-9][0-9]|100) COLOR=$RED
  ;;
esac

sketchybar --set ram.percent label="${MEMORY_USAGE}%" label.color=$COLOR \
           --push ram.graph  ${MEMORY_GRAPH}