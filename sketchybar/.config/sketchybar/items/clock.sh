#!/usr/bin/env bash

sketchybar --add item clock right                                \
           --set clock update_freq=$UPDATE_CLOCK                 \
                       icon.font="$FONT:Bold:14.0"               \
                       label.font="$LABEL_FONT:Regular:13.0"     \
                       script="$PLUGIN_DIR/clock.sh"             \
                       icon.color=$RED                           \
                       click_script="open -a 'Calendar'"         \
                                                                 \
           --add item temp right                                 \
           --set temp update_freq=$UPDATE_SLOW                   \
                      script="$PLUGIN_DIR/weather.sh"            \
                      label.font="$LABEL_FONT:Regular:13.0"      \
                      icon.font="$FONT:Bold:19.0"                \
                      click_script="open -a Weather"                \
                                                                 \
           --add bracket utils clock temp                        \
           --set         utils background.color=$SURFACE0        \
                               background.corner_radius=7        \
                               background.height=32              \
                               shadow=off                        \
                                                                 \
           --add item divider right                              \
           --set divider width=8                                 \
                         background.drawing=off                  \
                         icon.drawing=off                        \
                         label.drawing=off
