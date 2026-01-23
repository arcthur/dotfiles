#!/usr/bin/env bash

sketchybar --add item wifi right \
           --set wifi icon=󰖩 \
                      icon.font="$FONT:Bold:19.0" \
                      icon.color=$TEAL \
                      icon.padding_right=7 \
                      icon.padding_left=2 \
                      background.padding_right=1 \
                      click_script="open 'x-apple.systempreferences:com.apple.Network-Settings.extension'"
