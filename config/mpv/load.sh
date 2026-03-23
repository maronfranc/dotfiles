#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

TARGET_DIR="$HOME/.config/mpv"
FILE_1="mpv.conf"
FILE_2="./input.conf"

mkdir -p "$TARGET_DIR"

SRC_1="$PWD/$FILE_1"
SRC_2="$PWD/$FILE_2"
TARGET_1="$TARGET_DIR/$FILE_1"
TARGET_2="$TARGET_DIR/$FILE_2"

ln -sf "$SRC_1" "$TARGET_1"
ln -sf "$SRC_2" "$TARGET_2"
