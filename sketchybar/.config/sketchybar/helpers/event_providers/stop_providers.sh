#!/usr/bin/env bash
#
# stop_providers.sh - Stop all event providers

echo "Stopping event providers..."
killall cpu memory network battery 2>/dev/null || true
echo "Event providers stopped."
