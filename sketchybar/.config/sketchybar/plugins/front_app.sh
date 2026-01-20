#!/bin/bash

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ] || [ "$SENDER" = "aerospace_workspace_change" ]; then
  FOCUSED_WORKSPACE=""
  if command -v aerospace >/dev/null 2>&1; then
    FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null || true)"
  fi

  if [ -n "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" label="$FOCUSED_WORKSPACE::$INFO"
  else
    sketchybar --set "$NAME" label="$INFO"
  fi
fi
