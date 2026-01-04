#!/usr/bin/env bash

load_view() {
  local RESET='\033[0m'
  local BOLD='\033[1m'
  local ITALIC='\033[3m'
  local RED='\033[31m'
  local GREEN='\033[32m'
  local YELLOW='\033[33m'
  local CYAN='\033[36m'
  # local BRIGHT_CYAN='\033[1;96m'   
  local BLUE='\033[34m'
  local CPU_ICON="󰹑"
  local TEMP_ICON="󰔄"
  local RAM_ICON=""

  #/**
  # * Run an `echo -e ${input}` wrapping in `│` with fixed padding.
  # * @param $1 Input text to echo
  # * @return printf "│${input}${padding_spaces}│"
  # */
  pprint() {
    local input="$1"
    local max_width=45
    local visible=$(printf "%b" "$input" | sed -E 's/\x1B\[[0-9;]*[A-Za-z]//g')
    local visible_len=${#visible}
    local pad=$((max_width - visible_len)) # Calculate padding (never negative)
    ((pad < 0)) && pad=0
    printf "│%b%*s│\n" "$input" "$pad" "" # Print with borders
  }

  print_logo() {
    local CPU_CORES=$(nproc)
    local CPU_USAGE_PCT=$(top -bn1 | grep "Cpu(s)" |
      sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1 "%"}')

    local RAM_TOTAL=$(free -g | grep Mem | awk '{print $2}')
    local RAM_USED=$(free -g | grep Mem | awk '{print $3}')
    # local RAM_FREE=$(free -g | grep Mem | awk '{print $4}')
    local RAM_USED_PERCENT=$(free | grep Mem | awk '{print int($3/$2 * 100)}')

    if command -v sensors &>/dev/null; then
      local CPU_TEMP=$(sensors | grep -i 'Core 0' |
        awk '{print $3}' | sed 's/+//g' | sed 's/°C//g')
    else
      local CPU_TEMP="N/A"
    fi
    # Set color based on CPU Temperature using bc for floating-point comparison
    if (($(echo "$CPU_TEMP < 40" | bc -l))); then
      local CPU_COLOR=$BLUE
    elif (($(echo "$CPU_TEMP >= 40 && $CPU_TEMP <= 70" | bc -l))); then
      local CPU_COLOR=$YELLOW
    else
      local CPU_COLOR=$RED
    fi

    echo -e "┌─────────────────────────────────────────────┐"
    echo -e "│${YELLOW} ()      () ()()()()   ()()()()() ()      () ${RESET}│"
    echo -e "│${YELLOW} ()()  ()() ()      () ()         ()      () ${RESET}│"
    echo -e "│${YELLOW} () ()() () ()      () ()         ()      () ${RESET}│"
    echo -e "│${YELLOW} ()      () ()      () ()()()()    ()    ()  ${RESET}│"
    echo -e "│${YELLOW} ()      () ()      () ()           ()  ()   ${RESET}│"
    echo -e "│${YELLOW} ()      () ()      () ()            ()()    ${RESET}│"
    echo -e "│${YELLOW} ()      () ()()()()   ()()()()()     ()     ${RESET}│"
    echo -e "├─────────────────────────────────────────────┤"
    # pprint   "${CYAN}${BOLD}$CPU_ICON CPU Stats:${RESET}"
    pprint "$TEMP_ICON ${CYAN}CPU Temperature: ${BOLD}${CPU_COLOR}${CPU_TEMP}°C${RESET}"
    pprint "$CPU_ICON ${CYAN}CPU(${CPU_CORES} Cores) usage: ${BOLD}${GREEN}${CPU_USAGE_PCT}${RESET}"
    pprint "$RAM_ICON ${YELLOW}Total Memory: ${BOLD}${GREEN}${RAM_TOTAL} GB${RESET}"
    pprint "$RAM_ICON ${YELLOW}Used Memory:  ${BOLD}${GREEN}${RAM_USED} GB (${RAM_USED_PERCENT}%)${RESET}"
    # pprint "${CYAN}${BOLD}${RAM_ICON} Memory Stats:${RESET}"
    # pprint "$RAM_ICON  ${CYAN}Free Memory:  ${BOLD}${GREEN}${RAM_FREE} GB${RESET}"
    echo -e "└─────────────────────────────────────────────┘"
  }

  # Style path and add current git branch when in a git path.
  set_git_branch_in_prompt() {
    source /usr/share/git/completion/git-prompt.sh 2>/dev/null ||
      source /etc/bash_completion.d/git-prompt 2>/dev/null
    # local USER_HOST='\u@\h'
    local WPATH='\w'
    local GIT_PS1='$(__git_ps1 "(%s)")'
    export PS1="${YELLOW}${WPATH}${BLUE}${GIT_PS1}${RESET}\$ "
  }

  print_logo
  set_git_branch_in_prompt
}

# Ensure this script only runs in interactive shells
if [[ $- == *i* ]]; then
  load_view
fi
