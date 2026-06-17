#!/usr/bin/env bash
# Strict mode: fail fast and loudly.
set -e          # Stop on first error.
set -u          # Disallow unset variables.
set -o pipefail # Propagate pipeline failures.

CONFIG="root"

echo "Stopping Snapper timers..."
sudo systemctl disable --now snapper-timeline.timer || true
sudo systemctl disable --now snapper-cleanup.timer || true

echo "Deleting all snapshots from config: $CONFIG"

# Skip snapshot 0 (current filesystem state)
snapper -c "$CONFIG" list | awk 'NR>2 {print $1}' | while read -r num; do
    if [[ "$num" != "0" ]]; then
        echo "Deleting snapshot $num"
        sudo snapper -c "$CONFIG" delete "$num" || true
    fi
done

echo "Removing timeline settings..."
sudo snapper -c "$CONFIG" set-config \
    TIMELINE_CREATE=no \
    TIMELINE_CLEANUP=no

echo "Done."
