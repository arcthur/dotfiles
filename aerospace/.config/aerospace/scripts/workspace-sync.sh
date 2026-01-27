#!/bin/bash

# Sync workspaces across monitors: main=N, secondary=N+10
# Single monitor: switch to 1-10 only
# Dual monitors: sync main (1-10) and secondary (11-20)

set -euo pipefail

command -v aerospace >/dev/null 2>&1 || exit 0

target="${1:-}"
[[ "$target" =~ ^[0-9]+$ ]] || exit 0

# Count monitors
monitor_count="$(aerospace list-monitors | wc -l | tr -d ' ')"

if [ "$monitor_count" -gt 1 ]; then
  # Dual monitor: sync both
  focused_monitor="$(aerospace list-monitors --focused --format '%{monitor-name}')"
  aerospace workspace "$target" 2>/dev/null || true
  aerospace workspace "$((target + 10))" 2>/dev/null || true
  aerospace focus-monitor "$focused_monitor" 2>/dev/null || true
else
  # Single monitor: just switch workspace
  aerospace workspace "$target" 2>/dev/null || true
fi

# Direct update for faster response
APP="$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | cut -d'"' -f4)"
[ -n "$APP" ] && sketchybar --set front_app label="${target}::${APP}"

# Trigger spaces update immediately (don't wait for aerospace event)
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$target" &
