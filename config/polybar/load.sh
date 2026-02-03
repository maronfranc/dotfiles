#!/usr/bin/env bash
set -e

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# Source `confirm_and_run` helper function.
source "$DOTFILE_DIR/custom_bash/sourced_files/bash_functions.sh"

DELETE_TARGET="$HOME/.config/polybar"
TARGET="$HOME/.config"
SOURCE="$(pwd)"

confirm_and_run "Confirm delete: $DELETE_TARGET" \
    rm -rf $DELETE_TARGET 

ln -s "$SOURCE" "$TARGET" 
