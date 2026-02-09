#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

SRC="$PWD/yazi.desktop"
TARGET_DIR="$HOME/.local/share/applications"
TARGET="$TARGET_DIR/yazi.desktop"

rm -rf "$TARGET"

mkdir -p "$TARGET_DIR"
ln -s "$SRC" "$TARGET"

# Set as default file manager 
xdg-mime default yazi.desktop inode/directory
