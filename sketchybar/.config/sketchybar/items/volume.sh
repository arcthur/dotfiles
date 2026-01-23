#!/bin/bash

sketchybar --add item volumePopup right                            \
           --set volumePopup popup.drawing=off                     \
                             popup.height=32                       \
                             click_script="${POPUP_CLICK_SCRIPT}"  \
                             background.padding_left=1             \
                             label.padding_left=0                  \
                             label.padding_right=0                 \
                             icon.font="$FONT:Bold:19.0"           \
                             icon.color=$PINK                      \
                                                                   \
           --add item volume popup.volumePopup                     \
           --set volume  script="$PLUGIN_DIR/volume.sh"            \
           --subscribe volume volume_change                        \
                                                                   \
           --add slider volumeSlider popup.volumePopup 100         \
           --set volumeSlider script="sketchybar --set volumeSlider slider.percentage=\$INFO" \
                              slider.highlight_color=$BLUE         \
                              slider.background.height=10          \
                              slider.background.corner_radius=3    \
                              slider.background.color=$SURFACE0    \
           --subscribe volumeSlider volume_change
