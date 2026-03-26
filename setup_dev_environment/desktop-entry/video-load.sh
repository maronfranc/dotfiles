#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

TARGET_DIR="$HOME/.local/share/applications"
FILE="video.desktop"

SRC="$PWD/$FILE"
TARGET="$TARGET_DIR/$FILE"

rm -rf "$TARGET"

mkdir -p "$TARGET_DIR"
ln -s "$SRC" "$TARGET"

xdg-mime default "$FILE" video/mp4
xdg-mime default "$FILE" video/mpeg
xdg-mime default "$FILE" video/ogg
xdg-mime default "$FILE" video/webm
xdg-mime default "$FILE" video/avi
xdg-mime default "$FILE" video/mov
xdg-mime default "$FILE" video/flv
xdg-mime default "$FILE" video/wmv
xdg-mime default "$FILE" video/mpg
xdg-mime default "$FILE" video/mts
xdg-mime default "$FILE" video/m2ts
xdg-mime default "$FILE" video/mxf
xdg-mime default "$FILE" video/vob
xdg-mime default "$FILE" video/ts
xdg-mime default "$FILE" video/m4v
xdg-mime default "$FILE" video/3gp
xdg-mime default "$FILE" video/asf
xdg-mime default "$FILE" video/mts
xdg-mime default "$FILE" video/m2ts
