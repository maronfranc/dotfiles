#!/usr/bin/env bash

PROGRAMS_DIR="~/zzz_programs"
# Install neovim lastest
sudo apt remove neovim --purge
sudo apt autoremove autoclean clean

# Dependencies
sudo apt update
sudo apt install git build-essential cmake git pkg-config libtool g++ libunibilium4 libunibilium-dev \
    ninja-build gettext libtool libtool-bin autoconf automake unzip curl doxygen lua-term lua-term-dev luarocks

# Build
git clone https://github.com/neovim/neovim "${PROGRAMS_DIR}/neovim"
cd "${PROGRAMS_DIR}/neovim" || exit
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install

# Keymap commands uses "xclip" to copy and paste from neovim.
sudo apt install xclip
# "Neo-tree" uses "trash-cli" send files to trash.
sudo apt install trash-cli
# "Telescope" uses "ripgrep" to find files.
sudo apt install ripgrep
