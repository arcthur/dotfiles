#!/bin/bash

# Handler for workspace change events
# Syncs paired workspaces across monitors (N <-> N+10)
# Uses lock file to prevent recursive triggers

set -euo pipefail

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:$PATH"

LOCK_DIR="/tmp/aerospace_workspace_sync_lock"
FOCUSED_WORKSPACE="${AEROSPACE_FOCUSED_WORKSPACE:-}"

# Early exit conditions
command -v aerospace >/dev/null 2>&1 || exit 0
[[ "$FOCUSED_WORKSPACE" =~ ^[0-9]+$ ]] || exit 0

base_workspace="$FOCUSED_WORKSPACE"
if [ "$base_workspace" -gt 10 ]; then
  base_workspace="$((base_workspace - 10))"
fi

# Check if we're already syncing (prevent recursion)
if [ -e "$LOCK_DIR" ]; then
  now="$(date +%s)"
  mtime="$(stat -f %m "$LOCK_DIR" 2>/dev/null || echo 0)"
  if [ "$mtime" -gt 0 ] && [ $((now - mtime)) -gt 10 ]; then
    rm -rf "$LOCK_DIR"
  else
    exit 0
  fi
fi

# Count monitors
monitor_count="$(aerospace list-monitors --count 2>/dev/null || echo 1)"
monitor_count="$(printf '%s' "$monitor_count" | tr -d ' ')"

if [ "$monitor_count" -eq 2 ]; then
  # Determine paired workspace on the other monitor
  paired_workspace="$FOCUSED_WORKSPACE"
  if [ "$FOCUSED_WORKSPACE" -le 10 ]; then
    paired_workspace="$((FOCUSED_WORKSPACE + 10))"
  else
    paired_workspace="$((FOCUSED_WORKSPACE - 10))"
  fi

  # Get current visible workspaces to check if sync is needed
  visible_workspaces="$(aerospace list-workspaces --monitor all --visible 2>/dev/null || true)"

  # Check if the paired workspace is already visible on the other monitor
  if ! printf '%s\n' "$visible_workspaces" | grep -q "^${paired_workspace}$"; then
    # Create lock to prevent recursion
    if ! mkdir "$LOCK_DIR" 2>/dev/null; then
      exit 0
    fi
    trap 'rm -rf "$LOCK_DIR"' EXIT

    # Remember which monitor has focus
    focused_monitor="$(aerospace list-monitors --focused --format '%{monitor-name}' 2>/dev/null || true)"

    # Focus paired workspace on the other monitor
    aerospace workspace "$paired_workspace" 2>/dev/null || true

    # Restore focus to original monitor
    if [ -n "$focused_monitor" ]; then
      aerospace focus-monitor "$focused_monitor" 2>/dev/null || true
    fi

    # Release lock before notifying sketchybar to avoid UI skipping updates
    rm -rf "$LOCK_DIR"
    trap - EXIT
  fi
fi

# Notify sketchybar
if command -v sketchybar >/dev/null 2>&1; then
  sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$base_workspace" 2>/dev/null || true
fi
