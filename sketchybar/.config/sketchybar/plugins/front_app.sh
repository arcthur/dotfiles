#!/usr/bin/env bash

[[ $SENDER == front_app_switched ]] || exit 0
[[ -f /tmp/aerospace_workspace_sync_lock ]] && exit 0

APP_NAME=$INFO
WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)

# Normalize: 11-20 → 1-10
((WORKSPACE > 10)) 2>/dev/null && WORKSPACE=$((WORKSPACE - 10))

sketchybar --set "$NAME" label="${WORKSPACE:+$WORKSPACE::}$APP_NAME"
