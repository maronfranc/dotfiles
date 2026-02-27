#!/usr/bin/env bash

# Get list of running containers and format them for rofi menu
containers=$(docker ps --format "table {{.Names}} | {{.Status}} | {{.Ports}}" | tail -n +2)

# Check if there are any containers
if [ -z "$containers" ]; then
    notify-send "Docker" "No running containers found"
    exit 1
fi

# Add numbered prefixes to each container line
numbered_containers=$(echo "$containers" | awk '{print NR ") " $0}')

# Create rofi menu with formatted container list
selected=$(echo "$numbered_containers" | rofi -dmenu -p "Stop container" | awk '{printf "%s | %s\n", $2, $3}')

# Check if user selected a container
if [ -z "$selected" ]; then
    exit 0
fi

# Extract container name from selection (everything before the first space)
container_name=$(echo "$selected" | cut -d'|' -f1 | xargs)

# Stop the selected container
if docker stop "$container_name" >/dev/null 2>&1; then
    notify-send "Docker" "Container '$container_name' stopped successfully" -u low
else
    notify-send "Docker" "Failed to stop container '$container_name'" -u critical
fi
