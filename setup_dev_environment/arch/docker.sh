#!/usr/bin/env bash
set -e

sudo pacman -S docker docker-compose --needed
sudo systemctl start --now docker
sudo usermod -aG docker $USER

echo -n "Do you want to install NVIDIA GPU toolkit? [y/N]: "
read -r confirm_nvidia
if [[ "$confirm_nvidia" =~ ^[Yy] ]]; then
    # Add nvidia GPU toolkit.
    sudo pacman --needed -S nvidia-container-toolkit
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
fi

# docker.socket: 
# - Starts Docker only when a client connects
# - Stops it after inactivity (depending on config)
sudo systemctl enable docker.socket
