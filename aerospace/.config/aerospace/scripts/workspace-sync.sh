#!/bin/bash

# Sync workspaces across monitors: main=N, secondary=N+10

set -euo pipefail

command -v aerospace >/dev/null 2>&1 || exit 0

target="${1:-}"
[[ "$target" =~ ^[0-9]+$ ]] || exit 0

SYNC_LOCK="/tmp/aerospace_workspace_sync_lock"
touch "$SYNC_LOCK"

# Get current focused monitor before switching
focused_monitor="$(aerospace list-monitors --focused --format '%{monitor-name}')"

# Switch both monitors
aerospace workspace "$target" 2>/dev/null || true
aerospace workspace "$((target + 10))" 2>/dev/null || true

# Restore focus to original monitor
aerospace focus-monitor "$focused_monitor" 2>/dev/null || true

# Direct update (faster than event trigger), then release lock
APP="$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | cut -d'"' -f4)"
[ -n "$APP" ] && sketchybar --set front_app label="${target}::${APP}"
rm -f "$SYNC_LOCK"
