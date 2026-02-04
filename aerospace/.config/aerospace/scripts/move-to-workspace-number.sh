#!/bin/bash

set -euo pipefail

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:$PATH"

command -v aerospace >/dev/null 2>&1 || exit 0

target="${1:-}"
if [ -z "$target" ] || ! [[ "$target" =~ ^[0-9]+$ ]]; then
  exit 0
fi

focused_is_main="$(aerospace list-monitors --focused --format '%{monitor-is-main}' 2>/dev/null || true)"
focused_is_main="$(printf '%s' "$focused_is_main" | tr '[:upper:]' '[:lower:]')"

workspace="$target"
if [ "$focused_is_main" != "true" ]; then
  workspace=$((target + 10))
fi

aerospace move-node-to-workspace "$workspace"

if command -v sketchybar >/dev/null 2>&1; then
  sketchybar --trigger aerospace_windows_changed 2>/dev/null || true
fi
