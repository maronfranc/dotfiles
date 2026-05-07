#!/usr/bin/env bash
# Strict mode: fail fast and loudly.
set -e          # Stop on first error.
set -u          # Disallow unset variables.
set -o pipefail # Propagate pipeline failures.
echo -ne "\033]0;  Run ~/.local/bin script \007" # Script title.

select_options() {
    local prompt=$1

    fzf --height=80% \
        --border \
        --pointer="▶" \
        --prompt="$prompt" \
        --bind="j:down,k:up,h:abort,l:accept"
}

# Select and execute a symlinked files from `$HOME/.local/bin`.
prompt="Select a \`~/.local/bin\`  script to execute: "

# Get the selected symlinked file using fzf.
selected_file=$(find "$HOME/.local/bin" -maxdepth 1 -type l 2>/dev/null | select_options "$prompt")

# Check if a file was selected.
if [[ -n "$selected_file" ]]; then
    echo "Executing: $selected_file"
    exec "$selected_file"
else
    echo "No file selected... doing nothing."
    exit 1
fi
