#!/usr/bin/env bash
msg_title=" Podman stop"

containers=$(
    podman ps \
        --format "table {{.Names}} | {{.Status}} | {{.Ports}}" |
        tail -n +2 | \
    while read -r container_line; do
        container_name=$(echo "$container_line" | cut -d'|' -f1 | xargs)
        ip=$(podman inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name" 2>/dev/null)
        if [ -z "$ip" ]; then
            ip="N/A"
        fi
        # Extract status and ports, then replace ports with IP.
        status=$(echo "$container_line" | cut -d'|' -f2 | xargs)
        echo "$ip | $container_name | $status"
    done
)

# Check if there are any containers.
if [ -z "$containers" ]; then
    notify-send "$msg_title" "No running containers found."
    exit 1
fi

# Add stop all option at the start.
stop_msg="🛑 Stop all containers"
containers="$stop_msg"$'\n'"$containers"
# Add numbered prefixes to each container line.
numbered_containers=$(echo "$containers" | awk '{print NR "c) " $0}')

# Create rofi menu with formatted container list.
selected=$(echo "$numbered_containers" |
    rofi -dmenu -multi-select -p "Stop container")

# Check if stop all is selected.
if [[ "$selected" == *"$stop_msg"* ]]; then
    # TryRun my custom "stop all script" else run the simple command.
    podman-stop-all-containers || podman stop $(podman ps -q)
    exit 0
fi

selected=$(echo "$selected" | awk '{printf "%s | %s\n", $4, $5}')
# Check if user didn't selected a container.
if [[ ! "$selected" =~ [a-zA-Z] ]]; then
    exit 0
fi

# Extract container name from selection (everything before the first space).
container_names=$(echo "$selected" | cut -d'|' -f1 | xargs)

IFS=' ' read -ra container_array <<<"$container_names"
for container_name in "${container_array[@]}"; do
    # Stop the selected container
    if podman stop "$container_name" >/dev/null 2>&1; then
        notify-send -u low "$msg_title" \
            "Container '$container_name' stopped successfully."
    else
        notify-send -u critical -t 5000 "$msg_title" \
            "Failed to stop container '$container_name'."
    fi
done
