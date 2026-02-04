#!/bin/bash

# Sync workspaces across monitors: main=N, secondary=N+10
# Single monitor: switch to 1-10 only
# Dual monitors: sync main (1-10) and secondary (11-20)

set -euo pipefail

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:$PATH"

command -v aerospace >/dev/null 2>&1 || exit 0

LOCK_DIR="/tmp/aerospace_workspace_sync_lock"

target="${1:-}"
[[ "$target" =~ ^[0-9]+$ ]] || exit 0

# Avoid overlapping sync operations
acquired_lock=false
for _ in $(seq 1 20); do
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    acquired_lock=true
    break
  fi

  if [ -e "$LOCK_DIR" ]; then
    now="$(date +%s)"
    mtime="$(stat -f %m "$LOCK_DIR" 2>/dev/null || echo 0)"
    if [ "$mtime" -gt 0 ] && [ $((now - mtime)) -gt 10 ]; then
      rm -rf "$LOCK_DIR"
    fi
  fi

  sleep 0.05
done

[ "$acquired_lock" = true ] || exit 0
trap 'rm -rf "$LOCK_DIR"' EXIT

# Count monitors
monitor_count="$(aerospace list-monitors --count 2>/dev/null || echo 1)"
monitor_count="$(printf '%s' "$monitor_count" | tr -d ' ')"

if [ "$monitor_count" -eq 2 ]; then
  # Dual monitor: sync both
  focused_monitor="$(aerospace list-monitors --focused --format '%{monitor-name}' 2>/dev/null || true)"
  aerospace workspace "$target" 2>/dev/null || true
  aerospace workspace "$((target + 10))" 2>/dev/null || true
  if [ -n "$focused_monitor" ]; then
    aerospace focus-monitor "$focused_monitor" 2>/dev/null || true
  fi
else
  # Single monitor: just switch workspace
  aerospace workspace "$target" 2>/dev/null || true
fi

# Release lock before notifying sketchybar to avoid UI skipping updates
rm -rf "$LOCK_DIR"
trap - EXIT

# Direct update for faster response
if command -v sketchybar >/dev/null 2>&1; then
  APP="$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | cut -d'\"' -f4)"
  [ -n "$APP" ] && sketchybar --set front_app label="${target}::${APP}" 2>/dev/null || true

  # Trigger spaces update immediately (don't wait for aerospace event)
  sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$target" 2>/dev/null || true
fi
