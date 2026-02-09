#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures
# NOTE: `export PATH="$HOME/.local/bin:$PATH"` should be in $HOME/.bashrc
#   - Check if in path: `echo $PATH | tr ':' '\n' | grep local/bin`
SRC="$PWD/local-bin"
TARGET="$HOME/.local/bin"
# IFS = Internal Field Separator
# Set word splitting to only newline and tab (no spaces)
# Prevents breaking filenames that contain spaces
# Common safety setting for scripts that process file paths
IFS=$'\n\t'

mkdir -p "$TARGET"

# Ensure all shell scripts are executable.
find "$SRC" -type f -name '*.sh' -exec chmod +x {} +

# Look for all script inside $SRC and prepend dir path with `-`
find "$SRC" -type f -executable -print0 |
while IFS= read -r -d '' f; do
    rel_path="${f#$SRC/}"
    # Replace `/` with `-`.
    name="${rel_path//\//-}"
    # Keep keep basename.
    name="${name%.*}"
    rm -rf "$TARGET/$name"
    ln -sf "$f" "$TARGET/$name"
done
