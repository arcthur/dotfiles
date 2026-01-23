#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

FONT="JetBrainsMono Nerd Font"
APP_FONT="sketchybar-app-font"
LABEL_FONT="TX-02"

# Update frequencies (seconds)
UPDATE_CLOCK=1
UPDATE_FAST=3
UPDATE_MED=60
UPDATE_SLOW=300

# Bar configuration
bar=(
    height=40
    blur_radius=10
    position=top
    sticky=on
    padding_left=10
    padding_right=10
    color=$BAR_TRANSPARENT
    y_offset=0
    margin=0
    corner_radius=0
    border_width=0
    border_color=$LAVENDER
    shadow=on
    hidden=off
)

# Default item configuration
default=(
    icon.font="$FONT:Bold:17.0"
    icon.color=$WHITE
    label.font="$LABEL_FONT:Regular:13.0"
    label.color=$WHITE
    padding_left=5
    padding_right=5
    label.padding_left=4
    label.padding_right=4
    icon.padding_left=4
    icon.padding_right=4
    popup.background.border_width=1
    popup.background.corner_radius=5
    popup.background.border_color=$BLUE
    popup.background.color=$POPUP_BACKGROUND_COLOR
    popup.blur_radius=32
    popup.background.shadow.drawing=on
    background.y_offset=0
    background.height=32
    background.border_width=1
    background.border_color=$BAR_BORDER_COLOR
    background.corner_radius=5
    text.y_offset=0
    icon.y_offset=0
    label.y_offset=0
)

# Common scripts
POPUP_CLICK_SCRIPT='sketchybar --set $NAME popup.drawing=toggle'
POPUP_OFF='sketchybar --set $NAME popup.drawing=off'
