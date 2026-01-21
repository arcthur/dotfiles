#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
USER_NAME=$(id -un)
read -r CPU_SYS CPU_USER <<< "$(ps -A -o pcpu= -o user= | awk -v u="$USER_NAME" -v cores="$CORE_COUNT" '{cpu=$1; user=$2; if (user==u) user_sum+=cpu; else sys_sum+=cpu} END {printf "%.6f %.6f\n", sys_sum/(100*cores), user_sum/(100*cores)}')"


CPU_PERCENT="$(echo "$CPU_SYS $CPU_USER" | awk '{printf "%.0f\n", ($1 + $2)*100}')"

COLOR=$ACTUAL_WHITE
case "$CPU_PERCENT" in
  [1-2][0-9]) COLOR=$ACTUAL_WHITE
  ;;
  [3-6][0-9]) COLOR=$ORANGE
  ;;
  [7-9][0-9]|100) COLOR=$RED
  ;;
esac

sketchybar --set  cpu.percent label="${CPU_PERCENT}%" \
                              label.color=$COLOR \
           --push cpu.graph   $CPU_USER