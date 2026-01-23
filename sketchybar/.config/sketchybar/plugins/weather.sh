#!/usr/bin/env bash

CONFIG_DIR=${CONFIG_DIR:-$HOME/.config/sketchybar}
source "$CONFIG_DIR/colors.sh"

LOCATION=${WEATHER_LOCATION:-Singapore}
DATA=$(curl -fsSL "wttr.in/${LOCATION}?format=%t|%C" 2>/dev/null)
DATA=${DATA//+/}

if [[ -z $DATA || $DATA == *Unknown* ]]; then
    sketchybar --set "$NAME" label="--" icon=󰖐 icon.color="$TEAL"
    exit 0
fi

TEMP=${DATA%%|*}
TEMP=${TEMP//[°C ]/}
CONDITION=${DATA#*|}
CONDITION=${CONDITION,,}

HOUR=$(date +%H)
((HOUR >= 6 && HOUR < 18)) && DAY=1

if [[ -n $DAY ]]; then
    case $CONDITION in
        *snow*)                     ICON=󰼶 ;;
        *rain*|*shower*|*drizzle*)  ICON=󰖗 ;;
        *partly*|*overcast*)        ICON=󰖕 ;;
        *sunny*|*clear*)            ICON=󰖙 ;;
        *cloud*)                    ICON=󰖐 ;;
        *haze*|*mist*|*fog*)        ICON=󰖑 ;;
        *thunder*)                  ICON=󰖓 ;;
        *)                          ICON=󰖙 ;;
    esac
else
    case $CONDITION in
        *snow*)                     ICON=󰼶 ;;
        *rain*|*shower*|*drizzle*)  ICON=󰖗 ;;
        *clear*)                    ICON=󰖔 ;;
        *cloud*|*overcast*|*partly*) ICON=󰼱 ;;
        *fog*|*mist*|*haze*)        ICON=󰖑 ;;
        *thunder*)                  ICON=󰖓 ;;
        *)                          ICON=󰖔 ;;
    esac
fi

sketchybar --set "$NAME" label="${TEMP}°C" icon="$ICON" icon.color="$TEAL" \
           click_script="/usr/bin/open /System/Applications/Weather.app"
