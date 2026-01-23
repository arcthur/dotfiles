#!/usr/bin/env bash

storage=(
    icon=󰋊
    icon.color=$GREEN
    update_freq=$UPDATE_SLOW
    padding_left=10
    script="$PLUGIN_DIR/storage.sh"
)

sketchybar --add item storage right        \
           --set storage "${storage[@]}"   \
           --subscribe storage system_woke
