export HISTIGNORE="history*\
:ls*:cd*:echo*:cat*\
:clear:exit\
:node:python\
:nvim*:tmux*:fe:nnn:v"

# Use it in other file to append to a variable.
# `append_unique HISTIGNORE "another_command*:cmd2"`
# append_unique() {
#   local var_name="$1"
#   local new_values="$2"
#   local current_value
#
#   current_value="$(eval "printf '%s' \"\${$var_name}\"")"
#
#   IFS=':' read -r -a parts <<< "$new_values"
#
#   for part in "${parts[@]}"; do
#     case ":$current_value:" in
#       *":$part:"*) ;;
#       *)
#         if [[ -n "$current_value" ]]; then
#           current_value="$current_value:$part"
#         else
#           current_value="$part"
#         fi
#         ;;
#     esac
#   done
#
#   eval "export $var_name=\"\$current_value\""
# }

##### ##### Interactive shell + terminal output only ##### ##### 
[[ $- == *i* && -t 1 ]] || return

# Accept a confirmation message if accepted run all subsequent commands.
# Example: `confirm_and_run "Restart service?" echo "1" && echo "2"`
confirm_and_run() {
  local prompt_message=$1
  if [[ -z "$prompt_message" ]]; then
    echo -e " ${C_RED}${ICON_ERROR} Please provide a valid input.${C_NC}"
    echo -e " ${C_YELLOW}${ICON_INFO} Usage:${C_NC} ${C_BLUE}require_param <message> <commands>${C_NC}"
    echo -e " ${C_GREEN}${ICON_RIGHT}Example:${C_NC} 'confirm_and_run \"Prompt messag!?\" echo \"1\" && echo "2"'"
    return 1
  fi
  shift

  read -r -p "${prompt_message} [y/yes/s/sim]: " reply
  reply="${reply,,}" # lowercase
  if [[ "$reply" =~ ^(y|yes|s|sim)$ ]]; then
    "$@"
  else
    echo -e "${C_GRAY}No pattern matched, doing nothing.${C_NC}"
    return 1
  fi
}
