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

function gitlog() {
    local date_format="%Y-%m-%d ${C_BOLD}%H:%M"
    # - `%ad`: Date
    # - `%h`: Commit hash
    # - `%s`: Commit message
    local msg_format="%ad ${C_GRAY_DARK}%h${C_NC} ${C_CYAN}%s${C_NC}"

    git log \
        --date=format:"$date_format" \
        --pretty=format:"$msg_format" \
        "$@"
}

function gitunpushed_commits() {
    local current_branch=$(git branch --show-current)
    local commits=$(gitlog \
        origin/"$current_branch"..HEAD \
        2>/dev/null)

    if [[ -z "$commits" ]]; then
        echo "${C_GRAY}No unpushed commits.${C_NC}"
    else
        echo "$commits"
    fi
}

function gitstatus_staged() {
    # Replace diff with -> `git status --short` for relative import path.
    local staged_files=$(git diff --cached --name-status | grep '^[A-Z]' | awk \
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
    }')

    if [[ -z "${staged_files}" ]]; then
        echo -e "${C_BOLD}${C_GRAY_DARK}No file in git stage.${C_NC}"
        return
    fi

    echo "$staged_files"
}

function gitcommit_amend() {
    local message="${ICON_RIGHT}Run:  ${C_CYAN}git commit --amend --no-edit${C_NC}?

─────── Last commit ───────────────────
$(gitlog -1)
─────── Staged files ──────────────────
${C_BLUE}$(gitstatus_staged)${C_NC}
───────────────────────────────────────"
    confirm_and_run "$message" git commit --amend --no-edit
}

function gitpush_origin() {
    local current_branch=$(git branch --show-current)
    local commits_ahead=$(git rev-list --count HEAD...origin/$current_branch)
    if [[ "$commits_ahead" -eq 0 ]]; then
        echo "Nothing to push. All commits are already pushed to origin."
        echo "─────── Last commit ───────────────────"
        echo "$(gitlog -1)"
        return 0
    fi

    local C_1=$C_CYAN
    local C_2=$C_YELLOW
    local message="${ICON_RIGHT}Run:  ${C_BOLD}${C_CYAN}git push origin $current_branch${C_NC}?

╭─────── ${C_1}Git${C_NC} ───────────────────────────────╮
│• User name:  ${C_BOLD}$(git config --global user.name)${C_NC}
│• User email: ${C_BOLD}$(git config --global user.email)${C_NC}
├─────── ${C_1}Branch${C_NC} ────────────────────────────┤
│• ${C_BOLD}${C_CYAN}${current_branch}${C_NC}
├─────── ${C_2}Staged files (forgot to commit?)${C_NC} ──┤
│$(gitstatus_staged)
├─────── ${C_2}Commits to push!${C_NC} ──────────────────┤
$(gitunpushed_commits)
╰───────────────────────────────────────────╯"

    confirm_and_run "$message" git push origin "$current_branch"
}
