#!/usr/bin/env bash

export TERM="xterm-256color"

# SEE: https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-windowizer
function tmuxdev() {
    local target="main-session"
    if ! tmux has-session -t $target 2>/dev/null; then
        tmux new-session -s $target
        return
    fi
    echo -ne "\033]0;  Tmux main session\007"
    tmux attach -t $target
}
