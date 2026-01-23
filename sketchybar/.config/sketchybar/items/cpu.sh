#!/usr/bin/env bash

# CPU: text overlaid on graph background (compact stacked style)
sketchybar --add graph       cpu.graph right 35                  \
           --set cpu.graph   graph.color=$TEXT                  \
                             graph.fill_color=$OVERLAY2_50         \
                             width=0                             \
                             padding_right=0                     \
                             label.drawing=off                   \
                             icon.drawing=off                    \
                             background.height=30                \
                             background.drawing=off              \
                             background.color=$TRANSPARENT       \
                                                                 \
           --add item        cpu.top right                       \
           --set cpu.top     label.font="$LABEL_FONT:Regular:8"  \
                             label="CPU"                         \
                             label.color=$WHITE           \
                             icon.drawing=off                    \
                             width=0                             \
                             padding_right=5                     \
                             y_offset=6                          \
                             click_script="open -a 'Activity Monitor'"                          \
                                                                 \
           --add item        cpu.percent right                   \
           --set cpu.percent label.font="$LABEL_FONT:Regular:12" \
                             label.color=$WHITE           \
                             y_offset=-4                         \
                             padding_right=5                     \
                             width=40                            \
                             icon.drawing=off                    \
                             update_freq=$UPDATE_FAST            \
                             script="$PLUGIN_DIR/cpu.sh"         \
                             click_script="open -a 'Activity Monitor'"         \
                                                                 \
           --add item        cpu.spacer right                    \
           --set cpu.spacer  width=10                            \
                             background.drawing=off              \
                             icon.drawing=off                    \
                             label.drawing=off 
