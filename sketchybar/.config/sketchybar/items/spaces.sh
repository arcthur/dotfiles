#!/bin/bash

source "$PLUGIN_DIR/apple.sh"

sketchybar --add event aerospace_workspace_change

if command -v aerospace >/dev/null 2>&1; then
    for sid in $(aerospace list-workspaces --all); do
        sketchybar --add item space.$sid left                    \
            --subscribe space.$sid aerospace_workspace_change    \
            --set space.$sid                                     \
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
fi
