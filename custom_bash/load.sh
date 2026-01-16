#!/usr/bin/env bash

# Get the directory of this script (resolves symlinks too)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# File to be sourced (in the same directory)
SOURCE_FILE="$SCRIPT_DIR/source_files.sh"

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
