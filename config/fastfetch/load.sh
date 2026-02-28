#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

TARGET="$HOME/.config/fastfetch/config.jsonc"
SRC="$PWD/config.jsonc"

rm -rf "$TARGET" 
ln -sf "$SRC" "$TARGET" 
