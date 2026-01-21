#!/bin/bash

if [ -z "$INFO" ] || ! command -v jq >/dev/null 2>&1; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

STATE="$(echo "$INFO" | jq -r '.state')"

if [ "$STATE" = "playing" ]; then
  MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
  sketchybar --set $NAME label="$MEDIA" drawing=on
else
  sketchybar --set $NAME drawing=off
fi