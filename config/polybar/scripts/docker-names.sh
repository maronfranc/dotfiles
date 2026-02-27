#!/usr/bin/env bash
# Strict mode: fail fast and loudly.
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

# Docker container status script for polybar
# This script checks running containers and returns formatted output

# Docker's brand color (orange) - #2496ed
# Background color: #2496ed
# Foreground color: white

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker not installed"
    exit 1
fi

# Get count of running containers
count=$(docker ps --format "table {{.ID}}" | wc -l)
count=$((count - 1)) # Subtract 1 for header line

# If no containers running, hide the module
if [ "$count" -eq 0 ]; then
    echo ""
    exit 0
fi

ellipsis=5
container_names=$(docker ps --format "table {{.Names}}" \
  | tail -n +2 \
  | head -n 5 \
  | sed "s/^\(.\\{$ellipsis\\}\).*/\1.../")

# Prepare formatted output
output="$count"

# If we have names to show, add them
if [ -n "$container_names" ]; then
    output="$output) $container_names"
fi

echo "$output"
