#!/usr/bin/env bash

echo 'Installing TMUX...'
sudo apt install tmux
echo 'Installing TPM: Tmux Plugin Manager...'
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
 
echo 'TPM installed! Run the following:'
echo '1. Enter Tmux and press I(capital i) to install tmux.conf dependencies;'
echo '2. Reload Tmux server or kill it and reopen.`tmux kill-server &> /dev/null`.'
