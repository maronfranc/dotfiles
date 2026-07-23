#!/usr/bin/env bash
set -e
set -u
set -o pipefail

# Docker/Podman container status script for polybar.
# This script checks running containers and returns formatted output.
# Usage: ./polybar-containers.sh [docker|podman]

# Determine the container runtime command.
CMD=""

# If an argument is passed, use it (validate it).
if [ -n "${1:-}" ]; then
    if command -v "$1" &> /dev/null; then
        CMD="$1"
    else
        echo "Error: Command '$1' not found." >&2
        echo ""; exit 1
    fi
else
    # Auto-detect: Prefer docker if available, else podman, else fail.
    if command -v docker &> /dev/null; then
        CMD="docker"
    elif command -v podman &> /dev/null; then
        CMD="podman"
    fi
fi

# If no command found, return empty string (hidden in polybar).
if [ -z "$CMD" ]; then
    echo ""; exit 0
fi
# Check if the determined container runtime is installed.
if ! command -v "$CMD" &> /dev/null; then
    echo ""; exit 0
fi

# Get count of running containers.
# Note: 'podman ps' and 'docker ps' have similar output formats.
count=$($CMD ps --format "table {{.ID}}" | wc -l)
count=$((count - 1)) # Subtract 1 for header line.

if [ "$count" -le 0 ]; then
    echo "0"; exit 0 
fi

output="$count"

ellipsis=5
container_names=$($CMD ps --format "table {{.Names}}" \
  | tail -n +2 \
  | head -n 5 \
  | sed "s/^\(.\{$ellipsis\}\).*/\1…/" \
  | tr '\n' ',' \
  | sed 's/,$//')

# If we have names to show, add them.
if [ -n "$container_names" ]; then
    output="$output)$container_names"
fi

echo "$output"
