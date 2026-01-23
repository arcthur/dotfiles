#!/bin/bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
PLUGIN_DIR="${PLUGIN_DIR:-$CONFIG_DIR/plugins}"

source "$CONFIG_DIR/colors.sh"

WORKSPACE=$1

command -v aerospace >/dev/null 2>&1 || exit 0

# Extract bracket name from space name (space.X -> space_bracket.X)
BRACKET_NAME="${NAME/space./space_bracket.}"

# Get all visible workspaces (one per monitor)
# This includes the focused workspace plus any other monitor's current workspace
VISIBLE_WORKSPACES=$(aerospace list-workspaces --monitor all --visible 2>/dev/null || true)

# Check if this workspace is visible (current on any monitor)
IS_VISIBLE=false
while IFS= read -r ws; do
    if [ "$WORKSPACE" = "$ws" ]; then
        IS_VISIBLE=true
        break
    fi
done <<< "$VISIBLE_WORKSPACES"

# Check if this is the globally focused workspace (for extra highlight if needed)
IS_FOCUSED=false
if [ -n "$FOCUSED_WORKSPACE" ]; then
    [ "$WORKSPACE" = "$FOCUSED_WORKSPACE" ] && IS_FOCUSED=true
fi

# Check if this workspace has any windows
WINDOWS=$(aerospace list-windows --workspace "$WORKSPACE" 2>/dev/null)
HAS_WINDOWS=false
if [ -n "$WINDOWS" ] && echo "$WINDOWS" | grep -q '[^[:space:]]'; then
    HAS_WINDOWS=true
fi

# Dynamic visibility: show only if visible (current on any monitor) or has windows
if [ "$IS_VISIBLE" = true ] || [ "$HAS_WINDOWS" = true ]; then
    sketchybar --set $NAME drawing=on --set $BRACKET_NAME drawing=on
else
    sketchybar --set $NAME drawing=off --set $BRACKET_NAME drawing=off
    exit 0
fi

# Style based on visibility state (current workspace on any monitor)
if [ "$IS_VISIBLE" = true ]; then
    # Visible workspace: highlighted with double border effect
    sketchybar --animate tanh 20 --set $NAME \
        background.color=$BLUE \
        background.border_color=$SAPPHIRE \
        label.color=$CRUST \
        icon.color=$CRUST
    sketchybar --animate tanh 20 --set $BRACKET_NAME \
        background.border_color=$LAVENDER
else
    # Has windows but not focused: subtle appearance
    sketchybar --animate tanh 20 --set $NAME \
        background.color=$SURFACE0 \
        background.border_color=$SURFACE1 \
        label.color=$OVERLAY1 \
        icon.color=$OVERLAY1
    sketchybar --animate tanh 20 --set $BRACKET_NAME \
        background.border_color=$TRANSPARENT
fi

# Show app icons for this workspace (with deduplication using awk)
LABEL=$(echo "$WINDOWS" | awk -F' \\| ' '{print $2}' | sort -u | while read -r app; do
    app=$(echo "$app" | xargs)
    [ -z "$app" ] && continue
    icon="$("$PLUGIN_DIR/icon_map.sh" "$app")"
    [ -z "$icon" ] && icon=":default:"
    printf "%s" "$icon"
done)

sketchybar --animate tanh 10 --set $NAME icon="$LABEL"
