#!/usr/bin/env bash

CONFIG_DIR=${CONFIG_DIR:-$HOME/.config/sketchybar}
PLUGIN_DIR=${PLUGIN_DIR:-$CONFIG_DIR/plugins}
source "$CONFIG_DIR/colors.sh"

WORKSPACE=$1
command -v aerospace &>/dev/null || exit 0

BRACKET_NAME=${NAME/space./space_bracket.}
VISIBLE_WORKSPACES=$(aerospace list-workspaces --monitor all --visible 2>/dev/null)

# Check if visible
IS_VISIBLE=
while IFS= read -r ws; do
    [[ $WORKSPACE == "$ws" ]] && { IS_VISIBLE=1; break; }
done <<< "$VISIBLE_WORKSPACES"

# Check for windows
WINDOWS=$(aerospace list-windows --workspace "$WORKSPACE" 2>/dev/null)
HAS_WINDOWS=
[[ $WINDOWS =~ [^[:space:]] ]] && HAS_WINDOWS=1

# Show/hide
if [[ -n $IS_VISIBLE || -n $HAS_WINDOWS ]]; then
    sketchybar --set "$NAME" drawing=on --set "$BRACKET_NAME" drawing=on
else
    sketchybar --set "$NAME" drawing=off --set "$BRACKET_NAME" drawing=off
    exit 0
fi

# Style
if [[ -n $IS_VISIBLE ]]; then
    sketchybar --animate tanh 20 --set "$NAME" \
        background.color=$BLUE background.border_color=$SAPPHIRE \
        label.color=$CRUST icon.color=$CRUST \
               --set "$BRACKET_NAME" background.border_color=$LAVENDER
else
    sketchybar --animate tanh 20 --set "$NAME" \
        background.color=$SURFACE0 background.border_color=$SURFACE1 \
        label.color=$OVERLAY1 icon.color=$OVERLAY1 \
               --set "$BRACKET_NAME" background.border_color=$TRANSPARENT
fi

# App icons
LABEL=$(awk -F' \\| ' '{print $2}' <<< "$WINDOWS" | sort -u | while read -r app; do
    app=${app## }; app=${app%% }
    [[ -z $app ]] && continue
    printf "%s" "$("$PLUGIN_DIR/icon_map.sh" "$app")"
done)

sketchybar --animate tanh 10 --set "$NAME" icon="${LABEL:-}"
