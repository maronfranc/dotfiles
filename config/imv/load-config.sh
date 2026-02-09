#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

SRC="$PWD/config"
TARGET_DIR="$HOME/.config/imv"
TARGET="$TARGET_DIR/config"

mkdir -p "$TARGET_DIR"

rm -rf "$TARGET"
ln -s "$SRC" "$TARGET"
