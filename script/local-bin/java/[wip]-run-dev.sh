#!/usr/bin/env bash
# FIXME: script not working as expected.
#   Currently it spawing the processes but not killing them.

echo "Building and running with hot-reload."

# Start everything in a subshell so they share a process group.
(
    ./gradlew classes --continuous --quiet &
    ./gradlew bootRun
) &
GROUP_PID=$!

cleanup() {
    echo "Stopping process group..."
    kill -TERM -"$GROUP_PID" 2>/dev/null
    wait "$GROUP_PID" 2>/dev/null
}

trap cleanup INT TERM
wait "$GROUP_PID"
