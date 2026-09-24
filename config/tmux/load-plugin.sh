#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SOURCE="$SCRIPT_DIR/tmux-session-manager.sh"
TARGET_DIR="${HOME:?}/.local/bin"
TARGET="$TARGET_DIR/tmux-session-manager"

[[ -f "$SOURCE" ]] || {
    printf 'Session manager not found: %s\n' "$SOURCE" >&2
    exit 1
}

mkdir -p "$TARGET_DIR"
chmod +x "$SOURCE"
ln -sfn "$SOURCE" "$TARGET"
printf 'Linked %s -> %s\n' "$TARGET" "$SOURCE"
