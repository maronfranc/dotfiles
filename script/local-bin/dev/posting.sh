#!/usr/bin/env bash
# Script handle `posting` project directory create and access.
# Example usage: 
# 1. Run script name:   `script-name`.
# 2. Run with 1 param:  `script-name create`
# 3. Run with 2 params: `script-name create project-name`
set -e          # Stop on first error
set -o pipefail # Propagate pipeline failures
echo -ne "\033]0;🌐 Posting \007" # Script title.

C_CYAN="\033[0;36m"
C_RED=$'\033[31m'
C_YELLOW=$'\033[33m'
C_NC="\033[0m" # Color reset

POSTING_HOME="${HOME}/999_posting_collections"
ENV_PATH="${POSTING_HOME}/.env"
commands=("help" "create" "open" "delete" "edit_env")

if ! command -v fzf >/dev/null 2>&1; then
    echo -e "Please install ${C_CYAN}fzf${C_NC} and try again."
    exit 1
fi

if ! command -v posting >/dev/null 2>&1; then
    echo -e "Please install ${C_CYAN}posting${C_NC} and try again."
    exit 1
fi

select_items() {
    local prompt=$1

    fzf --height=20% \
        --border \
        --pointer="▶" \
        --prompt="$prompt" \
        --bind="j:down,k:up,h:abort,l:accept"
}

show_help() {
    echo -e "File paths:"
    echo -e "  • Collections:   ${C_YELLOW}${POSTING_HOME}${C_NC}"
    echo -e "  • Env variables: ${C_YELLOW}${ENV_PATH}${C_NC}"
    echo -e "Available commands:"
    echo -e "  • ${C_CYAN}help${C_NC}     - Show this help message."
    echo -e "  • ${C_CYAN}create${C_NC}   - Create posting directory."
    echo -e "  • ${C_CYAN}open${C_NC}     - Open a posting directory."
    echo -e "  • ${C_CYAN}delete${C_NC}   - Delete posting directory."
    echo -e "  • ${C_CYAN}edit_env${C_NC} - Nvim edit file in ${ENV_PATH}."
    # echo -e "  • ${C_CYAN}collection_list${C_NC} - List all posting directory."
    echo -e "Collection lists:"
    for f in "${POSTING_HOME}"/*; do
        echo -e "  • ${C_YELLOW}$(basename $f).${C_NC}"
    done
}

create_cmd() {
    local dir_name=$1
    if [ -z "$dir_name" ]; then
        printf "${C_CYAN}➜ Enter directory name to create${C_NC}: "
        read dir_name 
    fi

    mkdir -p "$POSTING_HOME/$dir_name"
    echo -e "Posting path $C_CYAN'$POSTING_HOME/$dir_name'$C_NC created."
}

open_cmd() {
    local dir_path

    if [ -n "$1" ]; then
        dir_path="$1"
    else
        dir_path=$(ls "$POSTING_HOME" 2>/dev/null | \
            select_items "Select posting path ➡️ ")
    fi

    if [ -z "$dir_path" ]; then
        echo "No posting dir selected."
        return 1
    fi

    if [ -d "$POSTING_HOME/$dir_path" ]; then
        posting --env "$ENV_PATH" -c "$POSTING_HOME/$dir_path"
    else
        echo "Posting '$POSTING_HOME/$dir_path' not found."
    fi
}

delete_cmd() {
    local dir_path

    if [ -n "$1" ]; then
        dir_path="$1"
    else
        dir_path=$(ls "$POSTING_HOME" 2>/dev/null | \
            select_items "Select posting path ➡️ ")
    fi

    if [ -z "$dir_path" ]; then
        echo "Param: <posting_dir_path>"
        return 1
    fi

    echo -e "Posting path $C_RED'$POSTING_HOME/$dir_path'$C_NC sent to trash."
    trash-put "$POSTING_HOME/$dir_path"
}

pick_command() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "fzf is not installed"
        exit 1
    fi

    selected=$(printf "%s\n" "${commands[@]}" | \
        select_items "Select command ➡️")

    if [ -z "$selected" ]; then
        echo "No command selected"
        exit 0
    fi

    run_command "$selected"
}

edit_cmd() {
    if command -v nvim >/dev/null 2>&1; then
        nvim "$ENV_PATH" && pick_command
    else
        echo -e "Please install ${C_CYAN}neovim${C_NC} and try again."
        exit 1
    fi
}

run_command() {
    case "$1" in
        help)     show_help     ;;
        create)   create_cmd $2 ;;
        open)     open_cmd   $2 ;;
        delete)   delete_cmd $2 ;;
        edit_env) edit_cmd      ;;
        *) 
            echo -e "⚠️ Unknown command ${C_YELLOW}\"$1\"${C_NC}." 
            show_help
        ;;
    esac
}

if [ -z "$1" ]; then
    pick_command
else
    run_command "$1" "$2"
fi
