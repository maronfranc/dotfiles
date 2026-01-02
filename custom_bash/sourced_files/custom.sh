#!/bin/bash

if [[ -z "$DOTFILE_DIR" ]] ; then echo "DOTFILE_DIR var is empty" ; fi
if [[ -z "$SOURCE_DIR" ]] ; then echo "SOURCE_DIR var is empty" ; fi

alias EDITOR="nvim"
alias VISUAL="nvim"
# Open `man` with neovim
# SEE: https://www.reddit.com/r/neovim/comments/g7ymvv/do_you_use_neovim_for_reading_your_man_pages/
# export MANPAGER='nvim +Man!' export MANWIDTH=999

alias nvimeditor_config="cd $DOTFILE_DIR/../neovim-config/ && nvim"
alias nvimdotfile_config="cd $DOTFILE_DIR && nvim"

function listen_keys() {
  stdbuf -o0 showkey -a | cat -
}

function random_string() {
  tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo
}

function convert_pdf_to_image() {
  local name=$1
  # filename=${file%.*} # remove any extension.
  # filename=$(basename "$name" .pdf) # remove pdf extension.
  pdftoppm "$PWD/$name.pdf" "$name" -png
}

alias fetch_btc_ticker24h="curl https://api.poloniex.com/markets/BTC_USDT/ticker24h"
