#!/bin/sh
# Overwrite  xdg-open to run TUI file manager as default for directory.

TERMINAL="${TERMINAL:-alacritty}"
TUI_FILE_MANAGER="yazi"

# If target is a directory → open yazi in terminal
if [ -d "$1" ]; then
    exec i3-msg exec "$TERMINAL -e $TUI_FILE_MANAGER \"$1\""
fi

# Otherwise fallback to real xdg-open
exec /usr/bin/xdg-open "$@"
