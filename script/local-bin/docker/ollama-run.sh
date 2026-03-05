#!/usr/bin/env bash

C_CYAN=$'\033[36m'
C_RED=$'\033[31m'
C_NC=$'\033[0m' # Reset color | No color.

select_options() {
    local prompt=$1

    fzf --height=20% \
        --border \
        --pointer="▶" \
        --prompt="$prompt" \
        --bind="j:down,k:up,h:abort,l:accept"
}

agent_names=("OLLAMA_CODE_AGENT" "OLLAMA_CHAT_AGENT")
# Collect available models from environment variables
models=()
for i in "${!agent_names[@]}"; do
    agent_name="${agent_names[$i]}"
    if [ -n "${!agent_name}" ]; then
        # set name in the list as "n) agent_name"
        models+=("$((i+1))) ${!agent_name}")
    fi
done

# Check if any models are set in the terminal.
if [ ${#models[@]} -eq 0 ]; then
    echo "Error:$C_RED Please set one of these variables in the terminal:$C_NC" >&2
    for agent in "${agent_names[@]}"; do
        echo "- $agent:$C_CYAN export $agent=\"model-chat:8b\"$C_NC" >&2
    done
    exit 1
fi

model_selected=$(printf '%s\n' "${models[@]}" | select_options "Select a model:")
# Extract agent_name from #"n) agent_name".
model_name=$(echo "$model_selected" | cut -d' ' -f2-)

docker exec -it ollama ollama run "$model_name"
