#!/usr/bin/env bash
set -e # Stop on first error

select_options() {
    local prompt=$1

    fzf --height=20% \
        --border \
        --pointer="▶" \
        --prompt="$prompt" \
        --bind="j:down,k:up,h:abort,l:accept"
}

# Set container name and action from arguments
CONTAINER_NAME="$1"
ACTION="$2"

# Get running containers names
containers=$(docker ps --format "{{.Names}}" 2>/dev/null)
if [[ -z "$containers" ]]; then
    echo "No running containers found."
    exit 1
fi

# Only prompt for selection if variables are empty
if [[ -z "$CONTAINER_NAME" ]]; then
    CONTAINER_NAME=$(echo "$containers" | select_options "Select container:")
fi

# Validate that the container exists
if ! docker ps --format "{{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    echo "Error: Container '$CONTAINER_NAME' not found or not running."
    exit 1
fi

CONTAINER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME" 2>/dev/null)

if [[ -z "$CONTAINER_IP" ]]; then
    echo "Container not found or has no IP."
    exit 1
fi

# Only prompt for action if not provided as argument
if [[ -z "$ACTION" ]]; then
    available_actions=("status" "on" "off")
    ACTION=$(printf '%s\n' "${available_actions[@]}" | select_options "Select action:")
fi

# Get Docker bridge gateway (host side)
HOST_IP=$(docker network inspect bridge -f '{{(index .IPAM.Config 0).Gateway}}')

RULE_SPEC="-s $CONTAINER_IP ! -d $HOST_IP -j DROP"

rule_exists() {
    sudo iptables -C DOCKER-USER $RULE_SPEC 2>/dev/null
}

case "$ACTION" in
off)
    if rule_exists; then
        echo "Internet already BLOCKED for $CONTAINER_NAME ($CONTAINER_IP)"
    else
        echo "Blocking internet for $CONTAINER_NAME ($CONTAINER_IP)"
        sudo iptables -I DOCKER-USER $RULE_SPEC
    fi
    ;;
on)
    if rule_exists; then
        echo "Restoring internet for $CONTAINER_NAME ($CONTAINER_IP)"
        sudo iptables -D DOCKER-USER $RULE_SPEC
    else
        echo "Internet already ALLOWED for $CONTAINER_NAME ($CONTAINER_IP)"
    fi
    ;;
status)
    if rule_exists; then
        echo "Status: BLOCKED"
    else
        echo "Status: ALLOWED"
    fi
    ;;
*)
    echo "Invalid action. Use 'on', 'off', or 'status'."
    exit 1
    ;;
esac
