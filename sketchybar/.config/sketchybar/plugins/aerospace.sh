#!/bin/bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
PLUGIN_DIR="${PLUGIN_DIR:-$CONFIG_DIR/plugins}"

source "$CONFIG_DIR/colors.sh"

WORKSPACE=$1

FOCUSED_WORKSPACE=""
if command -v aerospace >/dev/null 2>&1; then
    FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null || true)"
fi

if [ -n "$FOCUSED_WORKSPACE" ] && [ "$WORKSPACE" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME background.color=$BLUE background.drawing=on
else
    sketchybar --set $NAME background.color=$BACKGROUND_1 background.drawing=off
fi

command -v aerospace >/dev/null 2>&1 || exit 0

APPS=$(aerospace list-windows --workspace "$WORKSPACE" | awk -F' \\| ' '{print $2}' | sort | uniq)

LABEL=""
while IFS= read -r app; do
    app=$(echo "$app" | xargs)
    [ -z "$app" ] && continue
    icon="$("$PLUGIN_DIR/icon_map.sh" "$app")"
    [ -z "$icon" ] && icon=":default:"
    LABEL="$LABEL $icon"
done <<< "$APPS"

LABEL=$(echo "$LABEL" | xargs)

# Keep label as workspace id; render app icons in icon field.
sketchybar --set $NAME icon="$LABEL"
