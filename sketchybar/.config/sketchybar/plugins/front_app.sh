#!/bin/bash

# Display focused workspace and app name
# Skips update during workspace sync to prevent flicker

[ "$SENDER" = "front_app_switched" ] || exit 0

# Skip if workspace sync in progress
SYNC_LOCK="/tmp/aerospace_workspace_sync_lock"
[ -f "$SYNC_LOCK" ] && exit 0

APP_NAME="$INFO"
WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null || true)"

# Normalize workspace display: 11-20 shown as 1-10
if [ -n "$WORKSPACE" ] && [ "$WORKSPACE" -gt 10 ] 2>/dev/null; then
  WORKSPACE=$((WORKSPACE - 10))
fi

if [ -n "$WORKSPACE" ]; then
  sketchybar --set "$NAME" label="${WORKSPACE}::${APP_NAME}"
else
  sketchybar --set "$NAME" label="$APP_NAME"
fi
