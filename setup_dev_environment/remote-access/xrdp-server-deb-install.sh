#!/usr/bin/env bash

sudo apt install x11vnc

# Create password and store in `~/.vnc/passwd`
x11vnc -storepasswd
