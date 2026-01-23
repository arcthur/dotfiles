#!/usr/bin/env bash

# Network rates display with vertical stacking
SIZE=11
WIDTH=70

up=(
    width=0
    label.width=$WIDTH
    label.align=right
    update_freq=$UPDATE_FAST
    y_offset=5
    icon=⇡
    label.font.size=$SIZE
    icon.font.size=$SIZE
    icon.color=$PEACH
    script="$PLUGIN_DIR/network.sh"
)

down=(
    label.width=$WIDTH
    label.align=right
    y_offset=-5
    icon=⇣
    label.font.size=$SIZE
    icon.font.size=$SIZE
    icon.color=$SAPPHIRE
)

sketchybar --add item net.up right          \
           --set net.up "${up[@]}"          \
                                            \
           --add item net.down right        \
           --set net.down "${down[@]}"      \
                                            \
           --add bracket network wifi net.up net.down \
           --set         network background.color=$SURFACE0 \
                                  background.corner_radius=7 \
                                  background.height=32       \
                                  shadow=off                 \
                                                             \
           --add item net.divider right                      \
           --set net.divider width=8                         \
                             background.drawing=off          \
                             icon.drawing=off                \
                             label.drawing=off
