#!/usr/bin/env bash

sudo apt install openssh-server
sudo systemctl enable ssh

systemctl status ssh
# On client: 
#   - `ssh server_username@192.168.x.x`
#   - `ssh server_username@server_hostname.local`
