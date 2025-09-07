#!/bin/bash

RESET='\033[0m'
BACKGROUND_COLOR='\033[48;5;'
TEXT_COLOR='\033[38;5;'

print_color() {
    local bg_code=$1
    local text_code=$2
    local color_text="${bg_code}${text_code}m [CODE:${text_code}] ${RESET}"

    # echo -en "\033[48;5;${code}m \033[38;5;${code}m ${code} \033[0m"
    # echo -e "${BACKGROUND_COLOR}${bg_code}m ${TEXT_COLOR}${text_code}m ${bg_code} ${RESET}"

    # echo -en "${BACKGROUND_COLOR}${bg_code};${TEXT_COLOR}${text_code}${color_text}" # Text color
    # echo -e "${BACKGROUND_COLOR}${bg_code}m${TEXT_COLOR}${text_code}${color_text}" # BG color

    local text_color_command="${BACKGROUND_COLOR}${bg_code};${TEXT_COLOR}${text_code}${color_text}"
    local bg_color_command="${BACKGROUND_COLOR}${bg_code}m${TEXT_COLOR}${text_code}${color_text}"

    echo -en "$text_color_command"
    echo -e "$bg_color_command"
}

for code in {0..7} {8..15}; do
    print_color "$code" "$code"
done
