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
    if [ -z "$(git rev-parse --git-dir)" ]; then
        echo "${C_RED} Not in a git directory.${C_NC}"
        return 0
    fi

    if [ -z "$(git diff --cached --name-only)" ]; then
        local git_stage=""
        echo " Add files to ${C_CYAN}git stage${C_NC} before running ammend.${C_NC}"
        return 0
    fi

    local C_1=$C_CYAN
    local C_2=$C_YEllOW
    local msg
    msg+="╭─────── ${C_1} Last commit${C_NC} ──────────────────────────╮"$'\n'
    msg+="$(gitlog -1)"$'\n'
    msg+="├─────── ${C_2} Files to add to ${C_NC} ─────────────────────┤"$'\n'
    msg+="${C_BLUE}$(gitstatus_staged)${C_NC}"$'\n'
    msg+="╰────────────────────────────────────────────────╯"$'\n'
    msg+="${ICON_RIGHT} Run:  ${C_BOLD}${C_CYAN}git commit --amend --no-edit${C_NC}?"

    confirm_and_run "$msg" git commit --amend --no-edit
}

function gitpush_origin() {
    if [ -z "$(git rev-parse --git-dir)" ]; then
        echo "${C_RED} Not in a git directory.${C_NC}"
        return 0
    fi

    if ! git remote get-url origin >/dev/null 2>&1; then
        echo -e "${C_RED} No remote origin configured.${C_NC}"
        echo "To configure remote origin, run:"
        echo "  ${C_BOLD}git remote add origin <repository-url>${C_NC}"
        return 0
    fi

    local current_branch=$(git branch --show-current)
    local staged_files=$(git diff --cached --name-status)
    local user_name=$(git config --global user.name)
    local user_email=$(git config --global user.email)
    local commits_ahead=$(git rev-list --count HEAD...origin/$current_branch)
    if [[ "$commits_ahead" -eq 0 ]]; then
        echo "${C_YELLOW} Nothing to push. All commits are already pushed to origin.${C_NC}"
        echo "──────── Last 3 commits ─────────────────────────────"
        echo "$(gitlog -3)"
        return 0
    fi

    local C_1=$C_CYAN
    local C_2=$C_YELLOW
    local msg
    msg+="╭─────── ${C_1}Git${C_NC} ────────────────────────────────────╮"$'\n'
    msg+=$(pprint "• User name:  ${C_BOLD}${user_name}${C_NC}")$'\n'
    msg+=$(pprint "• User email: ${C_BOLD}${user_email}${C_NC}")$'\n'
    msg+="├─────── ${C_1} Branch${C_NC} ───────────────────────────────┤"$'\n'
    msg+=$(pprint "• ${C_BOLD}${C_CYAN}${current_branch}${C_NC}")$'\n'
    msg+="├─────── ${C_2}󰕒 Commits to push!${C_NC} ─────────────────────┤"$'\n'
    msg+="$(gitunpushed_commits)"$'\n'
    if [ -n "${staged_files}" ]; then
        msg+="├─────── ${C_BOLD}${C_RED}⚠ Staged files (forgot to commit?)${C_NC} ─────┤"$'\n'
        msg+="$(gitstatus_staged)"$'\n'
    fi
    msg+="╰────────────────────────────────────────────────╯"$'\n'
    msg+="${ICON_RIGHT} Run:  ${C_BOLD}${C_CYAN}git push origin $current_branch${C_NC}?"

    confirm_and_run "$msg" git push origin "$current_branch"
}

function gitprint_nested_unpushed() {
    local root_dir="${1:-.}"

    find "$root_dir" -type d -name ".git" | while read -r gitdir; do
        local repo_dir="$(dirname "$gitdir")"

        (
            cd "$repo_dir"
            # Skip repos without upstream.
            if ! git rev-parse --abbrev-ref --symbolic-full-name '@{u}' \
                >/dev/null 2>&1; then
                echo -e "🟥 No upstream: ${C_BOLD}${C_RED}${repo_dir}${C_NC}"
                exit 0
            fi

            unpushed_count="$(git rev-list --count @{u}..HEAD)"
            if [[ "$unpushed_count" -gt 0 ]]; then
                echo -e "╭─────── ${C_YELLOW}⚠ ${unpushed_count} Unpushed logs list${C_NC} ─────────────────╮"
                pprint  " ${C_BOLD}${C_BLUE}${repo_dir}${C_NC}"
                gitlog @{u}..HEAD
                echo -e "╰────────────────────────────────────────────────╯"
            fi
        )
    done
}

alias gitstash_all="git stash --include-untracked"
