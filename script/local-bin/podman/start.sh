#!/usr/bin/env bash
msg_title=" Podman start"

# Get list of stopped containers and format them for rofi menu.
containers=$(podman ps -aq --filter "status=exited" | \
xargs -I {} podman inspect --format '{{.State.FinishedAt}}   {{.Name}}' {} | \
sed -E 's/T/ /; s/\..*Z//' | \
sed -E 's/ \///' | \
sort -t '|' -k1,1r)

if [ -z "$containers" ]; then
    notify-send "$msg_title" "No stopped containers found"
    exit 1
fi

# Add numbered "<N>c" prefixes to each container line.
numbered_containers=$(echo "$containers" | awk '{print NR "c) " $0}')

# Create rofi menu with formatted container list.
selected=$(echo "$numbered_containers" |
    rofi -dmenu -multi-select -p "Start container" |
    awk '{printf "%s\n", $7}')

# Check if user selected a container.
if [[ ! "$selected" =~ [a-zA-Z] ]]; then
    exit 0
fi

# Format container names to be in a single line and with space separated names.
container_names=$(echo "$selected" | cut -d'|' -f1 | xargs)

# Start the selected containers.
IFS=' ' read -ra container_array <<<"$container_names"
for container_name in "${container_array[@]}"; do
    if podman start "$container_name" >/dev/null 2>&1; then
        notify-send -u low "$msg_title" \
            "Container '$container_name' started successfully"
    else
        notify-send -t 5000 -u critical "$msg_title" \
            "Failed to start container '$container_name'"
    fi
done
