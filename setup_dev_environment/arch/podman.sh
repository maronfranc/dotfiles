#!/usr/bin/env bash

sudo pacman -S podman podman-compose

systemctl --user enable --now podman.socket
# Test with: `podman run --rm hello-world`
