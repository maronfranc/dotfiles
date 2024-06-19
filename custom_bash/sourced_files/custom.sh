#!/bin/bash

if [[ -z "$DOTFILE_DIR" ]] ; then echo "DOTFILE_DIR var is empty" ; fi
if [[ -z "$SOURCE_DIR" ]] ; then echo "SOURCE_DIR var is empty" ; fi

function random_string() {
  tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo
}

# function convert_pdf_to_image() {
#   local name=$1
#   pdftoppm "$PWD/$name.pdf" "$name" -png
# }
alias gpunvidiawatch='bash $SOURCE_DIR/../scripts/watch-nvidia.sh'
alias xsetled='xset led named "Scroll Lock"' # Keyboard scroll lock

alias EDITOR="nvim"
alias VISUAL="nvim"
alias fetch_btc_ticker24h="curl https://api.poloniex.com/markets/BTC_USDT/ticker24h"

# alias codq='code . & exit'
alias nvimeditconfig='cd $DOTFILE_DIR/neovim-config/ && nvim'
alias alacrittyeditconfig='nvim ~/.config/alacritty/alacritty.yml'

##### ##### ##### ##### ##### Python ##### ##### ##### ##### #####
alias python_env_source='source ~/main_env/bin/activate'
# TODO: talib is not working with python 3.11. Check if is fixed in the future.
alias conda_env_create='conda create -n "main_dev" python=3.10 ipython'
# alias conda_env_activate='conda activate main_env'
alias python='python3'
alias pp='python3'
alias pip='pip3'
# alias conda_auto_start_disable='conda config --set auto_activate_base false'
# alias conda_auto_start_enable="conda init --reverse $SHELL"

# Open `man` with neovim
# SEE: https://www.reddit.com/r/neovim/comments/g7ymvv/do_you_use_neovim_for_reading_your_man_pages/
# export MANPAGER='nvim +Man!' export MANWIDTH=999
alias fe="nnn" # file explorer
alias qq="exit"

# SEE: https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-windowizer
function tmuxdev() {
  target="main-session"
  if ! tmux has-session -t $target 2> /dev/null; then
    tmux new-session -s $target
    return
  fi
  tmux attach -t $target
}

function tmuxhelptabs() {
  echo "Windows (tabs)"
  echo "  - c  create window"
  echo "  - w  list windows"
  echo "  - n  next window"
  echo "  - p  previous window"
  echo "  - f  find window"
  echo "  - ,  name window"
  echo "  - &  kill window"
}

# TODO: add to startup-script.
# https://unix.stackexchange.com/questions/684540/how-can-i-have-the-right-ctrl-key-behave-as-the-left-ctrl-key
# - Comment: https://unix.stackexchange.com/a/685816
function xsetrightctrl() {
  xmodmap -e "keycode 105 = Control_R NoSymbol Control_R"
  xmodmap -e "add control = Control_R"
}
alias xmodsetrightctrl="xsetrightctrl"
alias xinit="xsetrightctrl && xsetled"

##### ##### ##### ##### ##### Java ##### ##### ##### ##### #####
alias java_build="./gradlew build"
alias java_spring_run="./gradlew bootRun"
alias springrun="./gradlew bootRun"
##### ##### ##### ##### ##### Kubernetes ##### ##### ##### ##### #####
# alias kubectl="minikube kubectl --"
