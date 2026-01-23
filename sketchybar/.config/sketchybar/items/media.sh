#!/bin/bash

sketchybar --add item media right                                \
           --set media icon="󰎆"                                  \
                       icon.color=$MAUVE                        \
                       icon.padding=10                           \
                       icon.font.size=14                         \
                       background.color=$SURFACE0                 \
                       icon.padding_left=9                       \
                       background.corner_radius=7                \
                       background.height=32                      \
                       label.padding_right=5                     \
                       label.max_chars=15                        \
                       scroll_texts=on                           \
                       background.padding_right=5                \
                       shadow=off                                \
                       script="$PLUGIN_DIR/media.sh"             \
                       updates=on                                \
           --subscribe media media_change
