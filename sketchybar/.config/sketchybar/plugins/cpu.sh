#!/usr/bin/env bash

source "$HOME/.config/sketchybar/colors.sh"

read -r CPU_PERCENT CPU_USER <<< "$(ps -A -o pcpu= -o user= | awk -v u="$(id -un)" -v cores="$(sysctl -n machdep.cpu.thread_count)" '
    {if ($2==u) user+=$1; else sys+=$1}
    END {
        total = (sys + user) / (100 * cores)
        printf "%.0f %.6f", total * 100, user / (100 * cores)
    }
')"

case $CPU_PERCENT in
    [1-2][0-9])     COLOR=$WHITE ;;
    [3-6][0-9])     COLOR=$PEACH ;;
    [7-9][0-9]|100) COLOR=$RED ;;
    *)              COLOR=$WHITE ;;
esac

sketchybar --set cpu.percent label="${CPU_PERCENT}%" label.color=$COLOR \
           --push cpu.graph $CPU_USER
