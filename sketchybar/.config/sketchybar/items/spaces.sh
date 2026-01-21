#!/bin/bash

source "$PLUGIN_DIR/apple.sh"

sketchybar --add event aerospace_workspace_change

if command -v aerospace >/dev/null 2>&1; then
    # Multi-monitor support: assign each workspace to its monitor's display
    while IFS=' ' read -r monitor_id display_id monitor_name; do
        [ -z "$monitor_id" ] && continue

        for sid in $(aerospace list-workspaces --monitor "$monitor_id"); do
            sketchybar --add item space.$sid left                    \
                --subscribe space.$sid aerospace_workspace_change    \
                --set space.$sid                                     \
                display="$display_id"                                \
                background.color=$HIGHLIGHT                          \
                background.corner_radius=7                           \
                background.height=22                                 \
                background.drawing=off                               \
                label="$sid"                                         \
                label.font="$LABEL_FONT:Regular:13.0"                \
                label.padding_left=5                                 \
                label.padding_right=5                                \
                icon.drawing=on                                      \
                icon.font="$APP_FONT:Regular:16.0"                   \
                icon.padding_left=6                                  \
                icon.padding_right=6                                 \
                click_script="aerospace workspace $sid"              \
                script="$PLUGIN_DIR/aerospace.sh $sid"
        done
    done < <(aerospace list-monitors --format '%{monitor-id} %{monitor-appkit-nsscreen-screens-id} %{monitor-name}')
fi
