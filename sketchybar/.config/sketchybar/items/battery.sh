#!/usr/bin/env bash

sketchybar --add item battery right                             \
           --set battery script="$PLUGIN_DIR/battery.sh"        \
                         update_freq=$UPDATE_MED                \
                         click_script="open 'x-apple.systempreferences:com.apple.Battery-Settings.extension'"   \
                         icon.font="$FONT:Bold:18.0"            \
           --subscribe battery system_woke power_source_change
