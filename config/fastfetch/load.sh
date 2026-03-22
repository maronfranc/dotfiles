#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

TARGET_DIR="$HOME/.config/fastfetch"
FILE="config.jsonc"

TARGET="$TARGET_DIR/$FILE"
SRC="$PWD/$FILE"

mkdir -p "$TARGET_DIR"

rm -rf "$TARGET" 
ln -sf "$SRC" "$TARGET" 
