#!/bin/bash

# Global vars being used in other bash files
# DOTFILE_DIR is "../"
DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASH_DIR="$DOTFILE_DIR/script"
SOURCE_DIR="$BASH_DIR/bashrc-autoload"

# Source all files in $SOURCE_DIR directory.
for file_path in "$SOURCE_DIR"/*; do
    if [ -f "$file_path" ]; then
        source "$file_path"
    fi
done

if [ -d "$SOURCE_DIR/dont_commit" ]; then
    for file_path in "$SOURCE_DIR"/dont_commit/*; do
        if [ -f "$file_path" ]; then
            source "$file_path"
        fi
    done
fi
