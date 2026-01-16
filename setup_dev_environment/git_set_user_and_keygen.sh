#!/bin/bash
# Prompt used input and run:
# ```sh
# git config --global user.name "Name"
# git config --global user.email "email@example.com"
# ssh-keygen -t ed25519 -C "email@example.com"
# ```

prompt_input() {
    local prompt_message="$1"
    local input_variable="$2"
    read -rp "$prompt_message" "$input_variable"
}

validate_email() {
    local email="$1"
    local email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

    if [[ ! $email =~ $email_regex ]]; then
        echo "Invalid email format. Please try again."
        return 1
    fi

    return 0
}

echo "• Please provide the following git information:"
prompt_input "• Set your user.name: " user_name

while true; do
    prompt_input "• Set your user.email address: " user_email
    if validate_email "$user_email"; then
        break
    # else TODO: add option to disable validation
    #   echo "Do you wish disable email validation?"
    #   select yn in "Yes" "No"; do
    #       case $yn in
    #           Yes ) echo "Email disabled."; validation_enabled=0; break;;
    #           No ) echo "Ok, try again."; break;;
    #       esac
    #   done
    fi
done

# • Text styles
# 0: Reset / Normal display
# 4: Underline
# 7: Inverse
# 1: Bold
# • Foreground colors (text color):
# 30 to 37: Standard colors (black, red, green, etc.)
# 90 to 97: Bright colors (gray, bright red, bright green, etc.)
# • Background colors:
# 40 to 47: Standard colors
# 100 to 107: Bright colors
GREEN='\033[0;32m'
BRIGHT_CYAN='\033[1;96m'
# LIGHT_GREEN='\033[1;32m'
RESET='\033[0m'

user_name_command="git config --global user.name \"${user_name}\""
user_email_command="git config --global user.email \"${user_email}\""
generated_ssh_command="ssh-keygen -t ed25519 -C $user_email"
echo "• ----- ----- Command that will be executed ----- ----- "
echo -e "• Setting:    ${BRIGHT_CYAN}${user_name_command}${RESET}"
echo -e "• Setting:    ${BRIGHT_CYAN}${user_email_command}${RESET}"
echo -e "• Generating: ${BRIGHT_CYAN}${generated_ssh_command}${RESET}"
echo "• ----- ----- ----- Run commands? ----- ----- ----- ----- "
select yn in "Yes" "No"; do
    case $yn in
    Yes)
        echo "TODO: execute commands here..."
        break
        ;;
    No)
        echo "Exiting script..."
        exit 0
        ;;
    esac
done
# Be cautious when using eval, as it can pose security risks if the variable contains untrusted input.
# eval $user_name_command && eval $user_email_command && eval $generated_ssh_command
# "${user_name_command[@]}" && "${user_email_command [@]}" && "${generated_ssh_command[@]}"

echo "• ----- ----- Script executed with success ----- ----- ----- "
