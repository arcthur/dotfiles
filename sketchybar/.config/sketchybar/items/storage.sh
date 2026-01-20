#!/bin/bash

storage=(
    icon=󰋊
    icon.color=$GREEN
    update_freq=300
    script="$PLUGIN_DIR/storage.sh"
)

sketchybar --add item storage right \
    --set storage "${storage[@]}" \
    --subscribe storage system_woke
