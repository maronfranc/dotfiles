#!/usr/bin/env bash

# Get list of stopped containers and format them for rofi menu
containers=$(docker ps -a --format "table {{.Names}} | {{.Status}} | {{.Ports}}" | tail -n +2 | grep -i "exited\|stopped")

# Check if there are any stopped containers
if [ -z "$containers" ]; then
    notify-send "Docker" "No stopped containers found"
    exit 1
fi

# Add numbered prefixes to each container line
numbered_containers=$(echo "$containers" | awk '{print NR ") " $0}')

# Create rofi menu with formatted container list
selected=$(echo "$numbered_containers" | rofi -dmenu -p "Start container" | awk '{printf "%s | %s\n", $2, $3}')

# Check if user selected a container
if [ -z "$selected" ]; then
    exit 0
fi

# Extract container name from selection (everything before the first space)
container_name=$(echo "$selected" | cut -d'|' -f1 | xargs)

# Start the selected container
if docker start "$container_name" >/dev/null 2>&1; then
    notify-send "Docker" "Container '$container_name' started successfully" -u low
else
    notify-send "Docker" "Failed to start container '$container_name'" -u critical
fi
