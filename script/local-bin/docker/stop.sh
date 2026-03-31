#!/usr/bin/env bash
msg_title="󰡨 Docker stop"

# Get list of running containers and format them for rofi menu
containers=$(docker ps \
    --format "table {{.Names}} | {{.Status}} | {{.Ports}}" |
    tail -n +2)

# Check if there are any containers
if [ -z "$containers" ]; then
    notify-send "$msg_title" "No running containers found"
    exit 1
fi

# Add stop option at the start
stop_msg="🛑 Stop all containers"
containers="$stop_msg"$'\n'"$containers"
# Add numbered prefixes to each container line
numbered_containers=$(echo "$containers" | awk '{print NR ") " $0}')

# Create rofi menu with formatted container list
selected=$(echo "$numbered_containers" |
    rofi -dmenu -multi-select -p "Stop container")

# Check if user selected includes stop all option.
if [[ "$selected" == *"$stop_msg"* ]]; then
    # TryRun my custom "stop all script" else run the simple command.
    docker-stop-all-containers || docker stop $(docker ps -q)
    exit 0
fi

selected=$(echo "$selected" | awk '{printf "%s | %s\n", $2, $3}')
# Check if user didn't selected a container.
if [[ ! "$selected" =~ [a-zA-Z] ]]; then
    exit 0
fi

# Extract container name from selection (everything before the first space)
container_names=$(echo "$selected" | cut -d'|' -f1 | xargs)

IFS=' ' read -ra container_array <<<"$container_names"
for container_name in "${container_array[@]}"; do
    # Stop the selected container
    if docker stop "$container_name" >/dev/null 2>&1; then
        notify-send -u low "$msg_title" \
            "Container '$container_name' stopped successfully"
    else
        notify-send -u critical -t 5000 "$msg_title" \
            "Failed to stop container '$container_name'"
    fi
done
