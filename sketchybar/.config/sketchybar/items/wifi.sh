#!/bin/bash

WIFI_POPUP_OFF='sketchybar --set wifiPopup popup.drawing=off'

sketchybar --add item wifiPopup right                            \
           --set wifiPopup popup.drawing=off                     \
                           popup.height=32                       \
                           icon.padding_right=7                  \
                           icon.padding_left=2                   \
                           background.padding_right=1            \
                           icon=󰤨                                \
                           icon.font="$FONT:Bold:19.0"           \
                           click_script="${POPUP_CLICK_SCRIPT}"  \
                                                                 \
           --add item wifi popup.wifiPopup                       \
           --set wifi    icon=󰤨                                  \
                         icon.color=$GREY                   \
                         background.padding_right=12             \
                                                                 \
           --add item wifiSettings popup.wifiPopup               \
           --set wifiSettings icon=󱚾                             \
                              icon.color=$GREY              \
                              label="Settings"                   \
                              click_script="open '/System/Library/PreferencePanes/Network.prefPane/'; $WIFI_POPUP_OFF"
