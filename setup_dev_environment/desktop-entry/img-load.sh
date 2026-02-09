#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

SRC="$PWD/img.desktop"
TARGET_DIR="$HOME/.local/share/applications"
TARGET="$TARGET_DIR/img.desktop"

rm -rf "$TARGET"

mkdir -p "$TARGET_DIR"
ln -s "$SRC" "$TARGET"

# Set custom image viewer script as system default.
xdg-mime default img.desktop image/jpeg
xdg-mime default img.desktop image/png
xdg-mime default img.desktop image/webp
xdg-mime default img.desktop image/gif
xdg-mime default img.desktop image/bmp
xdg-mime default img.desktop image/tiff
xdg-mime default img.desktop image/avif
