#!/usr/bin/env bash

source "$HOME/.config/sketchybar/colors.sh"

BATT_INFO=$(pmset -g batt)
[[ $BATT_INFO =~ ([0-9]+)% ]] && BATT_PERCENT=${BASH_REMATCH[1]}
[[ $BATT_INFO == *"AC Power"* ]] && CHARGING=1

sketchybar --set "$NAME" icon.color=$OVERLAY2

if [[ -n $CHARGING ]]; then
    case $BATT_PERCENT in
        100)    ICON=󰂄 COLOR=$GREEN ;;
        9[0-9]) ICON=󰂋 COLOR=$GREEN ;;
        8[0-9]) ICON=󰂊 COLOR=$GREEN ;;
        7[0-9]) ICON=󰢞 COLOR=$GREEN ;;
        6[0-9]) ICON=󰂉 COLOR=$YELLOW ;;
        5[0-9]) ICON=󰢝 COLOR=$YELLOW ;;
        4[0-9]) ICON=󰂈 COLOR=$PEACH ;;
        3[0-9]) ICON=󰂇 COLOR=$PEACH ;;
        2[0-9]) ICON=󰂆 COLOR=$RED ;;
        1[0-9]) ICON=󰢜 COLOR=$RED ;;
        *)      ICON=󰢜 COLOR=$RED ;;
    esac
else
    case $BATT_PERCENT in
        100)    ICON=󰁹 COLOR=$GREEN ;;
        9[0-9]) ICON=󰂂 COLOR=$GREEN ;;
        8[0-9]) ICON=󰂁 COLOR=$GREEN ;;
        7[0-9]) ICON=󰂀 COLOR=$GREEN ;;
        6[0-9]) ICON=󰁿 COLOR=$YELLOW ;;
        5[0-9]) ICON=󰁾 COLOR=$YELLOW ;;
        4[0-9]) ICON=󰁽 COLOR=$PEACH ;;
        3[0-9]) ICON=󰁼 COLOR=$PEACH ;;
        2[0-9]) ICON=󰁻 COLOR=$RED ;;
        1[0-9]) ICON=󰁺! COLOR=$RED ;;
        *)      ICON=󰂎 COLOR=$RED ;;
    esac
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${BATT_PERCENT}%" label.color="$COLOR"
