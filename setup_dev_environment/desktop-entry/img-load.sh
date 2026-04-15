#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

TARGET_DIR="$HOME/.local/share/applications"
FILE="img.desktop"

SRC="$PWD/$FILE"
TARGET="$TARGET_DIR/$FILE"

rm -rf "$TARGET"

mkdir -p "$TARGET_DIR"
ln -s "$SRC" "$TARGET"

# Set custom image viewer script as system default.
xdg-mime default "$FILE" image/jpeg
xdg-mime default "$FILE" image/png
xdg-mime default "$FILE" image/webp
xdg-mime default "$FILE" image/gif
xdg-mime default "$FILE" image/bmp
xdg-mime default "$FILE" image/tiff
xdg-mime default "$FILE" image/avif
xdg-mime default "$FILE" image/svg
