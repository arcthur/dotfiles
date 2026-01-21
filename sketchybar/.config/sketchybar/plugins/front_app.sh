#!/bin/bash

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ] || [ "$SENDER" = "aerospace_workspace_change" ]; then
  FOCUSED_WORKSPACE=""
  APP_NAME="$INFO"

  if command -v aerospace >/dev/null 2>&1; then
    FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null || true)"
    # aerospace_workspace_change doesn't pass $INFO, so fetch app name manually
    if [ -z "$APP_NAME" ]; then
      APP_NAME="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null || true)"
    fi
  fi

  if [ -n "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" label="$FOCUSED_WORKSPACE::$APP_NAME"
  else
    sketchybar --set "$NAME" label="$APP_NAME"
  fi
fi
