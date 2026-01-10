#!/usr/bin/env bash

# ssh-keygen -t ed25519 -C "your_email@example.com""
function gitcreate_ssh() {
  local email
  read -p "➡️Enter your email address for SSH key (e.g., youremail@example.com): " email
  echo "Run: ssh-keygen -t ed25519 -C \"$email\""
}

# git config --global user.name "Name Name!"
function gitset_name() {
  local name
  read -p "➡️Enter your git name: " name
  git config --global user.name \"$name\"
}

# git config --global user.email "email@example.com"
function gitset_email() {
  local email
  read -p "➡️Enter your email address: " email
  git config --global user.email \"$email\"
}

function gitget_name_and_email() {
  git config --global user.name
  git config --global user.email
}

function gitcommit_ammend() {
  confirm_and_run \
    "  ${ICON_RIGHT}Run:  ${C_CYAN}git commit --amend --no-edit${C_NC}?" \
    git commit --amend --no-edit
}
