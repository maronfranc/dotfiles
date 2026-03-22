#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

FILE="config.yml"
TARGET_CONFIG="$HOME/.config/posting/$FILE"
SRC_CONFIG="$PWD/$FILE"

TARGET_THEME="$HOME/.local/share/posting/themes"
SRC_THEME="$PWD/themes"

rm -rf "$TARGET_THEME" 
rm -rf "$TARGET_CONFIG" 

ln -sf "$SRC_CONFIG" "$TARGET_CONFIG" 
ln -sf "$SRC_THEME" "$TARGET_THEME" 
