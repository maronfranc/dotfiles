export PATH="$HOME/.local/bin:$PATH"

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


if [[ -z "$DOTFILE_DIR" ]]; then echo "DOTFILE_DIR var is empty"; fi
if [[ -z "$SOURCE_DIR" ]]; then echo "SOURCE_DIR var is empty"; fi

alias nvimeditor_config="cd $DOTFILE_DIR/../neovim-config/ && nvim"
alias nvimdotfile_config="cd $DOTFILE_DIR && nvim"
alias v="nvim"
