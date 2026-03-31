#!/usr/bin/env bash

sudo pacman -S nvidia-utils 
sudo pacman -S nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
