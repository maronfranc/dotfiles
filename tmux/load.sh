#!/bin/bash

sudo rm -f /etc/tmux.conf
# sudo ln -s ./tmux.conf /etc/tmux.conf
sudo cp ./tmux.conf /etc/tmux.conf
tmux kill-server &>/dev/null
