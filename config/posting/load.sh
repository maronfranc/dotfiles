#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

TARGET_CONFIG="$HOME/.config/posting/config.yaml"
SRC_CONFIG="$PWD/config.yml"

TARGET_THEME="$HOME/.local/share/posting/themes"
SRC_THEME="$PWD/themes"

rm -rf "$TARGET_THEME" 
rm -rf "$TARGET_CONFIG" 

ln -sf "$SRC_CONFIG" "$TARGET_CONFIG" 
ln -sf "$SRC_THEME" "$TARGET_THEME" 
