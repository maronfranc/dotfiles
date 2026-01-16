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

function tmuxhelptabs() {
    echo "Windows (tabs)"
    echo "  - c  create window"
    echo "  - w  list windows"
    echo "  - n  next window"
    echo "  - p  previous window"
    echo "  - f  find window"
    echo "  - ,  name window"
    echo "  - &  kill window"
}
