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

# Install "xclip" to enable copy and paste from neovim.
sudo apt install xclip
# Install trash-cli to neo-tree plugin run send to trash command.
sudo apt install trash-cli
