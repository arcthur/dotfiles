#!/bin/bash

USB_POPUP_OFF='sketchybar --set ejectMenu popup.drawing=off'

sketchybar --add item ejectMenu right                            \
           --set ejectMenu popup.drawing=off                     \
                           popup.height=32                       \
                           icon=󰇮                                \
                           icon.font.size=15                     \
                           icon.padding_right=4                  \
                           icon.color=$LAVENDER                  \
                           icon.padding_left=0                   \
                           background.padding_right=0            \
                           background.padding_left=0             \
                           click_script="${POPUP_CLICK_SCRIPT}"  \
                                                                 \
           --add item fileStorage popup.ejectMenu                \
           --set fileStorage click_script="open /System/Volumes/Data/Volumes/Files; $USB_POPUP_OFF" \
                             label="Files"                       \
                             icon=󰉋                              \
                             icon.size=14                        \
                                                                 \
           --add item termFiles popup.ejectMenu                  \
           --set termFiles click_script="osascript /Users/srijan/Library/Scripts/files-iterm-window.scpt; $USB_POPUP_OFF" \
                           label="Files Terminal"                \
                           icon=                                 \
                                                                 \
           --add item generalStorage popup.ejectMenu             \
           --set generalStorage click_script="open /System/Volumes/Data/Volumes/General-T7; $USB_POPUP_OFF" \
                                label="General"                  \
                                icon=󰉖                           \
                                                                 \
           --add item termGeneral popup.ejectMenu                \
           --set termGeneral click_script="osascript /Users/srijan/Library/Scripts/general-iterm-window.scpt; $USB_POPUP_OFF" \
                             label="General Terminal"            \
                             icon=                               \
                                                                 \
           --add item backups popup.ejectMenu                    \
           --set backups click_script="open /System/Volumes/Data/Volumes/Backup\ T7; $USB_POPUP_OFF" \
                         label="Backups"                         \
                         icon=󰁯                                  \
                                                                 \
           --add item ejectAll popup.ejectMenu                   \
           --set ejectAll click_script='osascript -e "tell application \"Finder\" to eject (every disk whose ejectable is true)"; $USB_POPUP_OFF' \
                          label="Eject All"                      \
                          icon=󰇪
