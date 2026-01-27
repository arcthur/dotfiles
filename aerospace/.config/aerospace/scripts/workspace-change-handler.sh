#!/bin/bash

# Handler for workspace change events
# Syncs secondary monitor to match primary workspace (N -> N+10)
# Uses lock file to prevent recursive triggers

set -euo pipefail

LOCK_FILE="/tmp/aerospace_workspace_sync_lock"
FOCUSED_WORKSPACE="${AEROSPACE_FOCUSED_WORKSPACE:-}"

# Early exit conditions
command -v aerospace >/dev/null 2>&1 || exit 0
[[ "$FOCUSED_WORKSPACE" =~ ^[0-9]+$ ]] || exit 0

# Check if we're already syncing (prevent recursion)
if [ -f "$LOCK_FILE" ]; then
  # Still notify sketchybar for UI update
  sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$FOCUSED_WORKSPACE" &
  exit 0
fi

# Count monitors
monitor_count="$(aerospace list-monitors | wc -l | tr -d ' ')"

if [ "$monitor_count" -gt 1 ]; then
  # Determine target based on which workspace changed
  if [ "$FOCUSED_WORKSPACE" -le 10 ]; then
    # Primary workspace changed, sync secondary
    target="$FOCUSED_WORKSPACE"
    secondary_target="$((FOCUSED_WORKSPACE + 10))"
  else
    # Secondary workspace changed, sync primary
    target="$((FOCUSED_WORKSPACE - 10))"
    secondary_target="$FOCUSED_WORKSPACE"
  fi

  # Get current visible workspaces to check if sync is needed
  visible_workspaces="$(aerospace list-workspaces --monitor all --visible)"

  # Check if secondary is already at the right workspace
  if ! echo "$visible_workspaces" | grep -q "^${secondary_target}$"; then
    # Create lock to prevent recursion
    touch "$LOCK_FILE"
    trap 'rm -f "$LOCK_FILE"' EXIT

    # Remember which monitor has focus
    focused_monitor="$(aerospace list-monitors --focused --format '%{monitor-name}')"

    # Switch secondary workspace
    if [ "$FOCUSED_WORKSPACE" -le 10 ]; then
      aerospace workspace "$secondary_target" 2>/dev/null || true
    else
      aerospace workspace "$target" 2>/dev/null || true
    fi

    # Restore focus to original monitor
    aerospace focus-monitor "$focused_monitor" 2>/dev/null || true
  fi
fi

# Notify sketchybar
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$FOCUSED_WORKSPACE" &
