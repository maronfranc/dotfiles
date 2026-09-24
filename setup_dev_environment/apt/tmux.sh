#!/usr/bin/env bash

echo 'Installing TMUX and session manager dependencies...'
sudo apt install tmux jq fzf
echo 'Installing TPM: Tmux Plugin Manager...'
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo 'TPM installed! Execute the following steps:'
echo '1. Run load.sh;'
echo '2. Enter Tmux and press I(capital i) to install tmux.conf dependencies;'
echo '3. Reload Tmux server or kill it and reopen.`tmux kill-server &> /dev/null`.'
