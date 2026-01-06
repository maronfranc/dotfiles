#!/usr/bin/env bash

load_view() {
  local C_RESET='\033[0m'
  local C_BOLD='\033[1m'
  local C_ITALIC='\033[3m'
  local C_RED='\033[31m'
  local C_GREEN='\033[32m'
  local C_YELLOW='\033[33m'
  local C_CYAN='\033[36m'
  # local C_BRIGHT_CYAN='\033[1;96m'   
  local C_BLUE='\033[34m'
  local ICON_CPU="󰹑"
  local ICON_TEMP="󰔄"
  local ICON_RAM=""

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

  # Colorize temperature based on value
  color_temp() {
    local temp="$1"

    if (( $(echo "$temp < 40" | bc -l) )); then
      echo -e "${C_BLUE}${temp}°C${C_RESET}"
    elif (( $(echo "$temp <= 70" | bc -l) )); then
      echo -e "${C_YELLOW}${temp}°C${C_RESET}"
    else
      echo -e "${C_RED}${temp}°C${C_RESET}"
    fi
  }

  local thermal_data=$(
    paste <(cat /sys/class/thermal/thermal_zone*/type) \
          <(cat /sys/class/thermal/thermal_zone*/temp) |
    awk '{ printf "%s %.1f\n", $1, $2/1000 }'
  )

  # Print a temperature sensor if it exists
  print_sensor() {
    local sensor="$1"
    local description="$2"
    local temp
    temp=$(echo "$thermal_data" | awk -v s="$sensor" '$1==s {print $2}')

    if [[ -n "$temp" ]]; then
      pprint "${ICON_TEMP} ${C_RED}${description}${C_RESET}(${sensor}): $(color_temp "$temp")"
    fi
  }

  print_logo() {
    local cpu_cores=$(nproc)
    local cpu_usage_pct=$(top -bn1 | grep "Cpu(s)" |
      sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1 "%"}')
    local ram_total=$(free -g | grep Mem | awk '{print $2}')
    local ram_used=$(free -g | grep Mem | awk '{print $3}')
    # local ram_free=$(free -g | grep Mem | awk '{print $4}')
    local ram_used_percent=$(free | grep Mem | awk '{print int($3/$2 * 100)}')

    echo -e "┌─────────────────────────────────────────────┐"
    echo -e "│${C_YELLOW} ()      () ()()()()   ()()()()() ()      () ${C_RESET}│"
    echo -e "│${C_YELLOW} ()()  ()() ()      () ()         ()      () ${C_RESET}│"
    echo -e "│${C_YELLOW} () ()() () ()      () ()         ()      () ${C_RESET}│"
    echo -e "│${C_YELLOW} ()      () ()      () ()()()()    ()    ()  ${C_RESET}│"
    echo -e "│${C_YELLOW} ()      () ()      () ()           ()  ()   ${C_RESET}│"
    echo -e "│${C_YELLOW} ()      () ()      () ()            ()()    ${C_RESET}│"
    echo -e "│${C_YELLOW} ()      () ()()()()   ()()()()()     ()     ${C_RESET}│"
    echo -e "├─────────────────────────────────────────────┤"
    # pprint   "${C_CYAN}${C_BOLD}$ICON_CPU CPU Stats:${C_RESET}"
    print_sensor "x86_pkg_temp" "CPU"
    print_sensor "acpitz" "Motherboard"
    print_sensor "iwlwifi_1" "Wi-Fi card"
    pprint "$ICON_CPU ${C_CYAN}CPU(${cpu_cores} Cores) usage: ${C_BOLD}${C_GREEN}${cpu_usage_pct}${C_RESET}"
    pprint "$ICON_RAM ${C_YELLOW}Total Memory: ${C_BOLD}${C_GREEN}${ram_total} GB${C_RESET}"
    pprint "$ICON_RAM ${C_YELLOW}Used Memory:  ${C_BOLD}${C_GREEN}${ram_used} GB (${ram_used_percent}%)${C_RESET}"
    # pprint "${C_CYAN}${C_BOLD}${ICON_RAM} Memory Stats:${C_RESET}"
    # pprint "$ICON_RAM  ${C_CYAN}Free Memory:  ${C_BOLD}${C_GREEN}${ram_free} GB${C_RESET}"
    echo -e "└─────────────────────────────────────────────┘"
  }

  # Style path and add current git branch when in a git path.
  set_git_branch_in_prompt() {
    source /usr/share/git/completion/git-prompt.sh 2>/dev/null ||
      source /etc/bash_completion.d/git-prompt 2>/dev/null
    # local user_host='\u@\h'
    local wpath='\w'
    local git_psi='$(__git_ps1 "(%s)")'
    export PS1="${C_YELLOW}${wpath}${C_BLUE}${git_psi}${C_RESET}\$ "
  }

  print_logo
  set_git_branch_in_prompt
}

# Ensure this script only runs in interactive shells
if [[ $- == *i* ]]; then
  load_view
fi
unset -f load_view
