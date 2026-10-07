#!/usr/bin/env bash
# This script:
# 1. Counts down for MINUTES.
# 2. Stops all running containers.
# 3. Runs ACTION (suspend|poweroff), selected via fzf when omitted.
#
# Strict mode: fail fast and loudly.
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

MINUTES="${1:-}"
ACTION="${2:-}"

VALID_ACTIONS=(suspend poweroff)

usage() {
    echo "Usage: $0 MINUTES [${VALID_ACTIONS[*]}]"
    echo "Actions:"
    echo "  suspend   Suspend the system (systemctl suspend)"
    echo "  poweroff  Power off the system (systemctl poweroff)"
    echo ""
    echo "Example: $0 10 poweroff"
    echo "Omit the action to pick one interactively with fzf."
}

select_action() {
    command -v fzf >/dev/null 2>&1 || {
        echo "Error: fzf is not installed, so the action must be given explicitly."
        usage
        exit 1
    }

    printf '%s\n' "${VALID_ACTIONS[@]}" | fzf --height=25% \
        --border \
        --reverse \
        --prompt="Select action: " \
        --bind="j:down,k:up,h:abort,l:accept"
}

if [[ ! "$MINUTES" =~ ^[0-9]+$ ]] || ((MINUTES < 1)); then
    echo "Error: MINUTES must be a positive integer."
    usage
    exit 1
fi

# No action passed: ask with fzf. An aborted selection means "do nothing".
if [[ -z "$ACTION" ]]; then
    ACTION=$(select_action)
    if [[ -z "$ACTION" ]]; then
        echo "No action selected... doing nothing."
        exit 0
    fi
fi

case "$ACTION" in
    suspend | poweroff) ;;
    *)
        echo "Error: unknown action '$ACTION'."
        usage
        exit 1
        ;;
esac

SECONDS_TO_WAIT=$((MINUTES * 60))

echo "System will gracefully $ACTION in $MINUTES minute(s)."
echo "Press Ctrl+C to cancel."

sleep "$SECONDS_TO_WAIT"

echo "Stoping running containers..."
podman-stop-all-containers || true
docker-stop-all-containers || true

echo "Running '$ACTION' gracefully..."
systemctl "$ACTION"