#!/usr/bin/env bash
set -e
set -u
set -o pipefail

# Docker/Podman container status script for polybar.
# Shows the number of running containers; the container names are hidden
# by default and can be toggled with a middle mouse click.
# Usage: container-names.sh [docker|podman] [toggle]
#   toggle  Show/hide the container names next to the count.
#
# The polybar module re-runs this script every second (cheap: it only reads
# a cache file), so a toggle shows up right away. The container runtime
# itself is only queried every QUERY_INTERVAL seconds.

QUERY_INTERVAL=60
ellipsis=5
max_names=5

# Parse arguments: optional runtime (docker|podman) and optional `toggle`.
TOGGLE=0
ARG_CMD=""

for arg in "$@"; do
    if [ "$arg" = "toggle" ]; then
        TOGGLE=1
    else
        ARG_CMD="$arg"
    fi
done

# Determine the container runtime command.
CMD=""

if [ -n "$ARG_CMD" ]; then
    # Explicit runtime: hide the module when it is not installed.
    if ! command -v "$ARG_CMD" &> /dev/null; then
        echo ""; exit 0
    fi
    CMD="$ARG_CMD"
else
    # Auto-detect: Prefer docker if available, else podman, else fail.
    if command -v docker &> /dev/null; then
        CMD="docker"
    elif command -v podman &> /dev/null; then
        CMD="podman"
    fi
fi

# If no runtime is available, return empty string (hidden in polybar).
if [ -z "$CMD" ]; then
    echo ""; exit 0
fi

# State of the names toggle and the cached output of the runtime query.
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/polybar"
STATE_FILE="$STATE_DIR/container-names-$CMD.show"
CACHE_FILE="$STATE_DIR/container-names-$CMD.cache"
mkdir -p "$STATE_DIR" 2>/dev/null || true

# Toggle the container names display and exit.
if [ "$TOGGLE" -eq 1 ]; then
    if [ -f "$STATE_FILE" ]; then
        rm -f "$STATE_FILE"
    else
        touch "$STATE_FILE"
    fi
    exit 0
fi

# Read the cached output: "<unix-time> <count> <names>".
cache_time=0
cache_count=""
cache_names=""

if [ -f "$CACHE_FILE" ]; then
    read -r cache_time cache_count cache_names < "$CACHE_FILE" || true
fi

case "$cache_time" in ''|*[!0-9]*) cache_time=0 ;; esac
case "$cache_count" in ''|*[!0-9]*) cache_count="" ;; esac

now=$(date +%s)
count="$cache_count"
names="$cache_names"

# Refresh the cache when it is missing or expired.
if [ -z "$count" ] || [ $((now - cache_time)) -ge "$QUERY_INTERVAL" ]; then
    # Note: 'podman ps' and 'docker ps' have similar output formats.
    if ! new_count=$($CMD ps --format "table {{.ID}}" 2>/dev/null | wc -l); then
        # Runtime not available (e.g. daemon not running): hide the module.
        echo ""; exit 0
    fi
    new_count=$((new_count - 1)) # Subtract 1 for header line.

    if new_names=$($CMD ps --format "table {{.Names}}" 2>/dev/null \
      | sed -n "2,$((max_names + 1))p" \
      | sed "s/^\(.\{$ellipsis\}\).*/\1…/" \
      | tr '\n' ',' \
      | sed 's/,$//'); then
        names="$new_names"
    fi
    count="$new_count"

    printf '%s %s %s\n' "$now" "$count" "$names" 2>/dev/null > "$CACHE_FILE" || true
fi

# Nothing known yet (first run and the query failed): hide the module.
if [ -z "$count" ]; then
    echo ""; exit 0
fi

if [ "$count" -le 0 ]; then
    echo "0"; exit 0
fi

output="$count"

# If the names are toggled on, append them to the count.
if [ -f "$STATE_FILE" ] && [ -n "$names" ]; then
    output="$output)$names"
fi

echo "$output"
