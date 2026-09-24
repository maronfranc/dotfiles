#!/usr/bin/env bash

export TERM="xterm-256color"

# SEE: https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-windowizer
function tmuxdev() {
    local target="main-session"
    if ! tmux has-session -t $target 2>/dev/null; then
        tmux new-session -s $target
        return
    fi
    echo -ne "\033]0;  Tmux development session\007"
    tmux attach -t $target
}

function tmuxnew() {
    local target
    local consonants="bcdfghjklmnpqrstvwxyz"
    read -r -p "Session name (empty to random): " target
    if [[ -z "$target" ]]; then
        target="session-"
        for _ in {1..5}; do
            target+="${consonants:RANDOM % ${#consonants}:1}"
        done
    fi
    if ! tmux has-session -t "$target" 2>/dev/null; then
        tmux new-session -s "$target"
        return
    fi
    echo -ne "\033]0;  [$target] Tmux session\007"
    tmux attach -t "$target"
}
