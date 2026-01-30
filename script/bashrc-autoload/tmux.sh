#!/usr/bin/env bash

# SEE: https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-windowizer
function tmuxdev() {
    local target="main-session"
    if ! tmux has-session -t $target 2>/dev/null; then
        tmux new-session -s $target
        return
    fi
    tmux attach -t $target
}
