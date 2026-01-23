#!/usr/bin/env bash

# RAM: text overlaid on graph background (compact stacked style)
sketchybar --add graph       ram.graph right 35                  \
           --set ram.graph   graph.color=$TEXT                   \
                             graph.fill_color=$OVERLAY2_50       \
                             width=0                             \
                             padding_right=0                     \
                             label.drawing=off                   \
                             icon.drawing=off                    \
                             background.height=30                \
                             background.drawing=off              \
                             background.color=$TRANSPARENT       \
                                                                 \
           --add item        ram.top right                       \
           --set ram.top     label.font="$LABEL_FONT:Regular:8"  \
                             label="RAM"                         \
                             label.color=$WHITE                  \
                             icon.drawing=off                    \
                             width=0                             \
                             padding_right=5                     \
                             y_offset=6                          \
                                                                 \
           --add item        ram.percent right                   \
           --set ram.percent label.font="$LABEL_FONT:Regular:12" \
                             label.color=$WHITE                  \
                             y_offset=-4                         \
                             padding_right=5                     \
                             width=40                            \
                             icon.drawing=off                    \
                             update_freq=$UPDATE_FAST            \
                             script="$PLUGIN_DIR/memory.sh"      \
                                                                 \
           --add item        ram.spacer right                    \
           --set ram.spacer  width=10                            \
                             background.drawing=off              \
                             icon.drawing=off                    \
                             label.drawing=off

sketchybar --add bracket sysinfo battery storage cpu.graph cpu.top cpu.percent ram.graph ram.top ram.percent \
           --set         sysinfo background.color=$SURFACE0 \
                                  background.corner_radius=7 \
                                  background.height=32       \
                                  shadow=off                 \
                                                             \
           --add item sysinfo.divider right                  \
           --set sysinfo.divider width=8                     \
                                 background.drawing=off      \
                                 icon.drawing=off            \
                                 label.drawing=off
