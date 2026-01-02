export HISTIGNORE="history*\
:ls*:cd*:echo*\
:clear:exit\
:node:python\
:nvim*:tmux*:fe:nnn"

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
