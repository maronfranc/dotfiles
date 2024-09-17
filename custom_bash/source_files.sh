#!/bin/bash

# Global vars being used in other bash files 
# DOTFILE_DIR="$HOME/_dotfiles"
DOTFILE_DIR="/media/mainssd/2632-21C3/00000_movel/_dotfiles"
BASH_DIR="$DOTFILE_DIR/custom_bash"
SOURCE_DIR="$BASH_DIR/sourced_files"

# Source all files in $SOURCE_DIR directory. 
for file_path in "$SOURCE_DIR"/*; do
    if [ -f "$file_path" ]; then 
        source "$file_path";
    fi
done

if [ -d "$SOURCE_DIR/custom" ]; then
    for file_path in "$SOURCE_DIR"/custom/*; do
        if [ -f "$file_path" ]; then 
            source "$file_path";
        fi
    done
fi
