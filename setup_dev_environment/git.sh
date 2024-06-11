#!/bin/bash

git config --global user.name "My Name"
git config --global user.email "my.email@email.com"
ssh-keygen -t ed25519 -C "my.email@email.com"
