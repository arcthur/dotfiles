#!/bin/bash
# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
SECRETS_FILE="$CONFIG_DIR/secrets.sh"

if [ -f "$SECRETS_FILE" ]; then
  # shellcheck source=/dev/null
  source "$SECRETS_FILE"
fi

if [ -z "${LOCATION:-}" ] || ! command -v jq >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
  sketchybar --set "$NAME" label="--" icon="" icon.color="0xff8bd5ca"
  exit 0
fi

URL="https://api.weather.gov/gridpoints/FFC/${LOCATION}/forecast/hourly"
JSON="$(curl -fsSL "$URL" 2>/dev/null || true)"

TEMP="$(jq -r '.properties.periods[0].temperature // empty' <<<"$JSON" 2>/dev/null || true)"
ICON="$(jq -r '.properties.periods[0].shortForecast // empty' <<<"$JSON" 2>/dev/null || true)"
SKY="$(jq -r '.properties.periods[0].isDaytime // empty' <<<"$JSON" 2>/dev/null || true)"

if [ -z "$TEMP" ] || [ -z "$ICON" ] || [ -z "$SKY" ]; then
  sketchybar --set "$NAME" label="--" icon="" icon.color="0xff8bd5ca"
  exit 0
fi

weather_icon_map() {
	shopt -s extglob
	# check if first argument is true or false to determine whether day or night
	# then check if second argument wildcard contains a string for determining which icon to show
	# if no match, return default icon
	if [ "$1" = "true" ]; then # Daytime
		case $2 in
		*Snow*)
			icon_result=""
			;;
		*Rain* | *Showers*)
			icon_result=""
			;;
		*"Partly Sunny"* | *"Partly Cloudy"*)
			icon_result=""
			;;
		*Sunny* | *Clear* )
			icon_result=""
			;;
		*Cloudy*)
			icon_result=""
			;;
        *Haze*)
            icon_result=""
            ;;
		*)
			icon_result=""
			;;
		esac
	else
		case $2 in # Night
		*Snow*)
			icon_result=""
			;;
		*Rain* | *Showers*)
			icon_result=""
			;;
		*Clear*)
			icon_result=""
			;;
		*Cloudy*)
			icon_result=""
			;;
		*Fog*)
			icon_result=""
			;;
        *Haze*)
            icon_result="󰖑"
            ;;
		*)
			icon_result=""
			;;
		esac
	fi
	echo $icon_result
}

BARICON="$(weather_icon_map "$SKY" "$ICON")"

sketchybar --set "$NAME" label="${TEMP}°F" \
                   icon="${BARICON}" \
                   icon.color="0xff8bd5ca" \
                   click_script="/usr/bin/open /System/Applications/Weather.app"
