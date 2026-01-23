#!/usr/bin/env bash

sketchybar --add item space_separator left                       \
           --set space_separator icon=󰡙                          \
                                 icon.color=$PEACH              \
                                 padding_left=7                  \
                                 padding_right=7                 \
                                 label.drawing=off               \
                                                                 \
           --add item front_app left                             \
           --set front_app       script="$PLUGIN_DIR/front_app.sh" \
                                 icon.drawing=off                \
                                 background.height=22            \
                                 background.color=$OVERLAY2          \
                                 background.border_width=0       \
                                 padding_right=10                \
           --subscribe front_app front_app_switched \
                                                                 \
           --add bracket left_side front_app                     \
           --set         left_side background.padding_right=32   \
                                                                 \
           --add bracket spaces_group '/space\..*/' space_separator left_side \
           --set         spaces_group background.color=$SURFACE0 \
                                      background.padding_right=19 \
                                      shadow=off
