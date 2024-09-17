#!/bin/bash

if [[ -z "$DOTFILE_DIR" ]] ; then echo "DOTFILE_DIR var is empty" ; fi
if [[ -z "$SOURCE_DIR" ]] ; then echo "SOURCE_DIR var is empty" ; fi

function random_string() {
  tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo
}

function convert_pdf_to_image() {
  local name=$1
  pdftoppm "$PWD/$name.pdf" "$name" -png
}

alias gpunvidiawatch='bash $SOURCE_DIR/../scripts/watch-nvidia.sh'
alias xsetled='xset led named "Scroll Lock"' # Keyboard scroll lock

alias EDITOR="nvim"
alias VISUAL="nvim"
alias fetch_btc_ticker24h="curl https://api.poloniex.com/markets/BTC_USDT/ticker24h"

# alias codq='code . & exit'
alias nvimeditconfig="cd $DOTFILE_DIR/neovim-config/ && nvim"
alias alacrittyeditconfig="nvim $DOTFILE_DIR/alacritty/alacritty.yml"

# Open `man` with neovim
# SEE: https://www.reddit.com/r/neovim/comments/g7ymvv/do_you_use_neovim_for_reading_your_man_pages/
# export MANPAGER='nvim +Man!' export MANWIDTH=999
alias fe="nnn" # file explorer
alias qq="exit"

alias kubectl="minikube kubectl -- "
