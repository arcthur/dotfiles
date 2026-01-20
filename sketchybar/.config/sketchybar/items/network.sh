#!/bin/bash

# Network rates display with vertical stacking
SIZE=11
WIDTH=70

up=(
    width=0
    label.width=$WIDTH
    label.align=right
    update_freq=3
    y_offset=5
    icon=⇡
    label.font.size=$SIZE
    icon.font.size=$SIZE
    icon.color=$GREEN
    script="$PLUGIN_DIR/network.sh"
)

down=(
    label.width=$WIDTH
    label.align=right
    y_offset=-5
    icon=⇣
    label.font.size=$SIZE
    icon.font.size=$SIZE
    icon.color=$RED
)

sketchybar --add item net.up right \
    --set net.up "${up[@]}" \
    \
    --add item net.down right \
    --set net.down "${down[@]}"
