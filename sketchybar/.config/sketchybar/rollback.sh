#!/usr/bin/env bash
# Rollback script to restore Bash configuration

set -e

CONFIG_DIR="$HOME/.config/sketchybar"
BACKUP_FILE="$CONFIG_DIR/sketchybarrc.bash.backup"

if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "Error: Backup not found at $BACKUP_FILE"
    exit 1
fi

echo "Rolling back to Bash configuration..."
cp "$BACKUP_FILE" "$CONFIG_DIR/sketchybarrc"

echo "Restarting sketchybar..."
brew services restart sketchybar 2>/dev/null || sketchybar --reload

echo "Rollback complete!"
echo "To switch back to Lua, restore sketchybarrc with the Lua version."
