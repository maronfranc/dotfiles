export HISTIGNORE="history*\
:ls*:cd*:echo*:cat*\
:clear:exit\
:node:python\
:nvim*:tmux*:fe:nnn:v"
export HISTCONTROL=ignoredups

# Open `man` with neovim
# SEE: https://www.reddit.com/r/neovim/comments/g7ymvv/do_you_use_neovim_for_reading_your_man_pages/
# export MANPAGER='nvim +Man!' export MANWIDTH=999
export TERMINAL="alacritty"
export EDITOR="nvim"
export VISUAL="nvim"

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
