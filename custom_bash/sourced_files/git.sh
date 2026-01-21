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

function gitlast_commit() {
    git log -1 --date=format:'%Y-%m-%d %H:%M' \
        --pretty=format:"%h %ad
${C_CYAN}%s${C_NC}"
}

function gitstatus_staged() {
    # Replace diff with -> `git status --short` for relative import path.
    git diff --cached --name-status | grep '^[A-Z]' | awk \
        -v C_BLUE="$C_BLUE" \
        -v C_GREEN="$C_GREEN" \
        -v C_RED="$C_RED" \
        -v C_NC="$C_NC" '
    {
        status = substr($0, 1, 1)
        if (status == "M")
            printf "%s%s%s\n", C_BLUE, $0, C_NC
        else if (status == "A")
            printf "%s%s%s\n", C_GREEN, $0, C_NC
        else if (status == "D")
            printf "%s%s%s\n", C_RED, $0, C_NC
        else
            print $0
    }'
}

function gitcommit_amend() {
    local message="${ICON_RIGHT}Run:  ${C_CYAN}git commit --amend --no-edit${C_NC}?

─────── Last commit ───────────────────
$(gitlast_commit)
─────── Staged files ── ─────── ───────
${C_BLUE}$(gitstatus_staged)${C_NC}
───────────────────────────────────────"
    confirm_and_run "$message" git commit --amend --no-edit
}
