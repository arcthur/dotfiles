#!/usr/bin/env bash
#
# start_providers.sh - Compile and start event providers for SketchyBar
#
# Usage: ./start_providers.sh [interval]
#   interval: Update interval in seconds (default: 2)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INTERVAL="${1:-2}"

# Compile if needed
compile_if_needed() {
    local dir=$1
    local binary=$2

    if [[ ! -f "$SCRIPT_DIR/$dir/$binary" ]] || \
       [[ "$SCRIPT_DIR/$dir/$binary.c" -nt "$SCRIPT_DIR/$dir/$binary" ]]; then
        echo "Compiling $dir..."
        make -C "$SCRIPT_DIR/$dir" >/dev/null 2>&1
    fi
}

# Kill existing providers
killall cpu memory network battery 2>/dev/null || true

# Compile all providers
compile_if_needed "cpu_load" "cpu"
compile_if_needed "memory_load" "memory"
compile_if_needed "network_load" "network"
compile_if_needed "battery_load" "battery"

echo "Starting event providers (interval: ${INTERVAL}s)..."

# Start providers in background
"$SCRIPT_DIR/cpu_load/cpu" "$INTERVAL" "cpu_update" &
"$SCRIPT_DIR/memory_load/memory" "$INTERVAL" "memory_update" &
"$SCRIPT_DIR/network_load/network" "en0" "$INTERVAL" "network_update" &
"$SCRIPT_DIR/battery_load/battery" "battery_update" &

echo "Event providers started:"
echo "  - cpu_load: $SCRIPT_DIR/cpu_load/cpu"
echo "  - memory_load: $SCRIPT_DIR/memory_load/memory"
echo "  - network_load: $SCRIPT_DIR/network_load/network"
echo "  - battery_load: $SCRIPT_DIR/battery_load/battery (adaptive interval)"
