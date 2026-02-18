#!/usr/bin/env bash
# Script handle `posting` project directory create and access.
# Example usage: 
# 1. Run script name:   `script-name`.
# 2. Run with 1 param:  `script-name create`
# 3. Run with 2 params: `script-name create project-name`
#
set -e          # Stop on first error
set -o pipefail # Propagate pipeline failures

C_CYAN="\033[0;36m"
C_RED=$'\033[31m'
C_YELLOW=$'\033[33m'
C_NC="\033[0m" # Color reset

POSTING_HOME="$HOME/999_posting_collections"
commands=("help" "path" "create" "list" "open" "delete")

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
    echo "Available commands:"
    echo -e "  • ${C_CYAN}help${C_NC}   - Show this help message."
    echo -e "  • ${C_CYAN}create${C_NC} - Create posting directory."
    echo -e "  • ${C_CYAN}list${C_NC}   - List all posting directory."
    echo -e "  • ${C_CYAN}open${C_NC}   - Open a posting directory."
    echo -e "  • ${C_CYAN}delete${C_NC} - Delete posting directory."
}

show_path() {
    echo -e ${C_CYAN}$POSTING_HOME${C_NC}
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

list_cmd() {
    echo -e "PATH: $C_YELLOW$POSTING_HOME$C_NC"
    for f in "$POSTING_HOME"/*; do
        # printf "    %b• %s%b\n" "$C_CYAN" "$(basename "$f")" "$C_NC"
        echo -e "    $C_CYAN• $(basename $f)$C_NC"
    done
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
        posting -c "$POSTING_HOME/$dir_path"
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
run_command() {
    case "$1" in
        help)   show_help     ;;
        path)   show_path     ;;
        list)   list_cmd      ;;
        create) create_cmd $2 ;;
        open)   open_cmd   $2 ;;
        delete) delete_cmd $2 ;;
        *) 
            printf "⚠️ Unknown command $C_YELLOW\"$1\"$C_NC. " 
            show_help
        ;;
    esac
}

if [ -z "$1" ]; then
    pick_command
else
    run_command "$1" "$2"
fi
