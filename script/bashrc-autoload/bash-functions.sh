#!/usr/bin/env bash

# Accept a confirmation message if accepted run all subsequent commands.
# Example: `confirm_and_run "Restart service?" echo "1" && echo "2"`
confirm_and_run() {
    local prompt_message=$1
    if [[ -z "$prompt_message" ]]; then
        echo -e " ${C_RED}${ICON_ERROR} Please provide a valid input.${C_NC}"
        echo -e " ${C_YELLOW}${ICON_INFO} Usage:${C_NC} ${C_BLUE}require_param <message> <commands>${C_NC}"
        echo -e " ${C_GREEN}${ICON_RIGHT}Example:${C_NC} 'confirm_and_run \"Prompt messag!?\" echo \"1\" && echo "2"'"
        return 1
    fi
    shift

    read -r -p "${prompt_message} [y/yes/s/sim]: " reply
    reply="${reply,,}" # lowercase
    if [[ "$reply" =~ ^(y|yes|s|sim)$ ]]; then
        "$@"
    else
        echo -e "${C_GRAY}No pattern matched, doing nothing.${C_NC}"
        return 1
    fi
}
