#!/bin/bash

sketchybar --add item battery right                              \
           --set battery script="$PLUGIN_DIR/battery.sh"  \
                         update_freq=$UPDATE_MED                \
                         click_script="${POPUP_CLICK_SCRIPT}"    \
                         icon.font="$FONT:Bold:18.0"             \
                         padding_left=10                         \
           --subscribe battery system_woke power_source_change
