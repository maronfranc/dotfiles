#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

TARGET_DIR="$HOME/.config/imv"
FILE="config"

SRC="$PWD/$FILE"
TARGET="$TARGET_DIR/$FILE"

mkdir -p "$TARGET_DIR"

rm -rf "$TARGET"
ln -s "$SRC" "$TARGET"
