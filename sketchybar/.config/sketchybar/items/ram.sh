#!/bin/bash

# RAM: text overlaid on graph background (compact stacked style)
sketchybar --add item        ram.top right                       \
           --set ram.top     label.font="$LABEL_FONT:Regular:8" \
                             label="RAM"                         \
                             label.color=$ACTUAL_WHITE              \
                             icon.drawing=off                    \
                             width=0                             \
                             padding_right=5                     \
                             y_offset=6                          \
                                                                 \
           --add item        ram.percent right                   \
           --set ram.percent label.font="$LABEL_FONT:Regular:12"   \
                             label.color=$ACTUAL_WHITE              \
                             y_offset=-4                         \
                             padding_right=5                     \
                             width=40                            \
                             icon.drawing=off                    \
                             update_freq=2                       \
                             script="$PLUGIN_DIR/memory.sh"      \
                                                                 \
           --add graph       ram.graph right 35                  \
           --set ram.graph   graph.color=$WHITE                  \
                             graph.fill_color=$GREY              \
                             width=0                             \
                             padding_right=-30                   \
                             label.drawing=off                   \
                             icon.drawing=off                    \
                             background.height=30                \
                             background.drawing=off              \
                             background.color=$TRANSPARENT       \
                                                                 \
           --add item        ram.spacer right                    \
           --set ram.spacer  width=10                            \
                             background.drawing=off              \
                             icon.drawing=off                    \
                             label.drawing=off
