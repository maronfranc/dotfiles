#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

TARGET_DIR="$HOME/.config/picom"
FILE="picom.conf"
SRC="$PWD/$FILE"
TARGET="$TARGET_DIR/$FILE"
SOURCE_DIR="$(pwd)/script"
TARGET_DIR="$TARGET_DIR/script"

# Create parent directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# If TARGET_DIr already exists, remove it
if [ -e "$TARGET_DIR" ] || [ -L "$TARGET_DIR" ]; then
    echo "Removing existing target: $TARGET_DIR"
    rm -rf "$TARGET_DIR"
fi

rm -rf "$TARGET"
ln -s "$SRC" "$TARGET"

# Add execute permission to scripts.
for file in ./script/*.sh; do
    [ -f "$file" ] && chmod +x "$file"
done

# Create the symlink
ln -s "$SOURCE_DIR" "$TARGET_DIR"

echo "Symlink created:"
echo "$TARGET_DIR -> $SOURCE_DIR"
