#!/bin/bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
PLUGIN_DIR="${PLUGIN_DIR:-$CONFIG_DIR/plugins}"

source "$CONFIG_DIR/colors.sh"

WORKSPACE=$1

command -v aerospace >/dev/null 2>&1 || exit 0

# Get all visible workspaces (one per monitor)
VISIBLE_WORKSPACES=$(aerospace list-workspaces --monitor all --visible 2>/dev/null || true)

# Check if this workspace is visible on any monitor
IS_VISIBLE=false
while IFS= read -r ws; do
    if [ "$WORKSPACE" = "$ws" ]; then
        IS_VISIBLE=true
        break
    fi
done <<< "$VISIBLE_WORKSPACES"

if [ "$IS_VISIBLE" = true ]; then
    sketchybar --set $NAME background.color=$BLUE background.drawing=on
else
    sketchybar --set $NAME background.color=$BACKGROUND_1 background.drawing=off
fi

# Show app icons for this workspace
APPS=$(aerospace list-windows --workspace "$WORKSPACE" 2>/dev/null | awk -F' \\| ' '{print $2}' | sort | uniq)

LABEL=""
while IFS= read -r app; do
    app=$(echo "$app" | xargs)
    [ -z "$app" ] && continue
    icon="$("$PLUGIN_DIR/icon_map.sh" "$app")"
    [ -z "$icon" ] && icon=":default:"
    LABEL="$LABEL $icon"
done <<< "$APPS"

LABEL=$(echo "$LABEL" | xargs)

sketchybar --set $NAME icon="$LABEL"
