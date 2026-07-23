#!/usr/bin/env bash
# Stop all running Docker containers.
# A simple `podman stop $(podman ps -q)` works the same but without notifications.
msg_title="󰡨 Docker stop running containers"

running_containers=$(podman ps --format "{{.ID}}:{{.Names}}")
if [ -z "$running_containers" ]; then
    notify-send "$msg_title" "No running containers found" -u low
    exit 0
fi

msg="Stopping all running containers:"$'\n'
counter=1
# Loop formating all names as a numbered list.
while IFS= read -r name; do
    msg+="$counter) $name"$'\n'
    ((counter++))
done <<<$(echo "$running_containers" | cut -d':' -f2)

notify-send "$msg_title" "$msg" -t 3000

# Stop all containers with notification.
for container in $running_containers; do
    c_id=$(echo "$container" | cut -d':' -f1)
    c_name=$(echo "$container" | cut -d':' -f2)
    if ! podman stop "$c_id" >/dev/null 2>&1; then
        notify-send "$msg_title" "Failed to stop container: $c_name ($c_id)"
    fi
done

notify-send "$msg_title" "All containers stopped" -u low -t 1000
