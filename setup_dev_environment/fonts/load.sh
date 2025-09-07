#!/usr/bin/env bash
# SEE list:https://www.nerdfonts.com/font-downloads
# SEE used font: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.0/Hack.zip

font_dir=~/.fonts
font_file_link="$font_dir/HackNerdFont-Regular.ttf"
# Download and unzip it here(./HackNerdFont-Regular.ttf)
font_file_local="$(pwd)/HackNerdFont-Regular.ttf"

mkdir -p -- $font_dir
rm -rf $font_file_link

ln -s $font_file_local $font_file_link
