#!/usr/bin/env bash
set -e

sudo pacman -S docker docker-compose
sudo systemctl start --now docker
# sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# docker.socket: 
# - Starts Docker only when a client connects
# - Stops it after inactivity (depending on config)
# sudo systemctl enable docker.socket
