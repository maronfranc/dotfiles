#!/usr/bin/env bash
# Packages: `xorg-xprop xorg-xwininfo`

# Get active window ID
WIN_ID=$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}')

# Normalize (remove 0x prefix for filename safety)
WIN_ID_CLEAN=${WIN_ID#0x}

STATE_DIR="/tmp/i3_transparency"
STATE_FILE="$STATE_DIR/$WIN_ID_CLEAN"

mkdir -p "$STATE_DIR"

if [ -f "$STATE_FILE" ]; then
    picom-trans -w "$WIN_ID" -o 100
    rm "$STATE_FILE"
else
    # Window 75% transparency
    picom-trans -w "$WIN_ID" -o 75
    touch "$STATE_FILE"
fi
