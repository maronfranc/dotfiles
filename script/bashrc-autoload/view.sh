#!/usr/bin/env bash

# Interactive shell + terminal output only
[[ $- == *i* && -t 1 ]] || return

# ----- ----- Define colors globally here ----- -----
C_NC=$'\033[0m' # Reset color | No color.
C_BOLD=$'\033[1m'
C_ITALIC=$'\033[3m'
C_RED=$'\033[31m'
C_GREEN=$'\033[32m'
C_GRAY=$'\033[90m' # dark gray (bright black)
C_YELLOW=$'\033[33m'
C_CYAN=$'\033[36m'
C_BLUE=$'\033[34m'
# C_BRIGHT_CYAN=$'\033[1;96m'
ICON_CPU="󰹑"
ICON_TEMP="󰔄"
ICON_RAM=""
ICON_ERROR=""
ICON_INFO=""
ICON_RIGHT="➡️"

set_git_branch_in_prompt() {
    source /usr/share/git/completion/git-prompt.sh 2>/dev/null ||
        source /etc/bash_completion.d/git-prompt 2>/dev/null
    # local user_host='\u@\h'
    local wpath='\w'
    local git_psi='$(__git_ps1 "(%s)")'
    export PS1="${C_YELLOW}${wpath}${C_BLUE}${git_psi}${C_NC}\$ "
}
set_git_branch_in_prompt
unset -f set_git_branch_in_prompt

fastfetch
