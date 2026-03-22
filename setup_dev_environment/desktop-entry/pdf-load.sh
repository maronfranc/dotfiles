#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

TARGET_DIR="$HOME/.local/share/applications"
FILE="pdf.desktop"

SRC="$PWD/$FILE"
TARGET="$TARGET_DIR/$FILE"

rm -rf "$TARGET"

mkdir -p "$TARGET_DIR"
ln -s "$SRC" "$TARGET"

# Set custom PDF viewer script as system default.
xdg-mime default "$FILE" application/pdf
