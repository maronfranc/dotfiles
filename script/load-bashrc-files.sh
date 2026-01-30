#!/usr/bin/env bash
# Source all `./bashrc_autoload/` files in `$HOME/.bashrc`.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/bashrc-source-files.sh"

BASHRC="$HOME/.bashrc"
SOURCE_LINE="source \"$SOURCE_FILE\""

# Append only if not already present
if ! grep -Fxq "$SOURCE_LINE" "$BASHRC"; then
    echo "" >>"$BASHRC"
    echo "# Source custom files directory" >>"$BASHRC"
    echo "$SOURCE_LINE" >>"$BASHRC"

    echo "Added to ~/.bashrc:"
    echo "$SOURCE_LINE"
else
    echo "Already present in ~/.bashrc"
fi
