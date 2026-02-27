#!/usr/bin/env bash

sudo pacman -S nvidia-utils nvidia-container-toolkit docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
