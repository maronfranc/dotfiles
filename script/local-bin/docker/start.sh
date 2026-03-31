#!/usr/bin/env bash
msg_title="󰡨 Docker start"

# Get list of stopped containers and format them for rofi menu
containers=$(docker ps -a \
    --format "table {{.Names}} | {{.Status}} | {{.Ports}}" |
    tail -n +2 |
    grep -i "exited\|stopped" |
    sort -r)

if [ -z "$containers" ]; then
    notify-send "$msg_title" "No stopped containers found"
    exit 1
fi

# Add numbered prefixes to each container line
numbered_containers=$(echo "$containers" | awk '{print NR ") " $0}')

# Create rofi menu with formatted container list
selected=$(echo "$numbered_containers" |
    rofi -dmenu -multi-select -p "Start container" |
    awk '{printf "%s | %s\n", $2, $3}')

# Check if user selected a container
if [[ ! "$selected" =~ [a-zA-Z] ]]; then
    exit 0
fi

# Extract container name from selection (everything before the first space)
container_names=$(echo "$selected" | cut -d'|' -f1 | xargs)

# Start the selected containers
IFS=' ' read -ra container_array <<<"$container_names"
for container_name in "${container_array[@]}"; do
    if docker start "$container_name" >/dev/null 2>&1; then
        notify-send -u low "$msg_title" \
            "Container '$container_name' started successfully"
    else
        notify-send -t 5000 -u critical "$msg_title" \
            "Failed to start container '$container_name'"
    fi
done
