#!/usr/bin/env bash
# SEE theme:
#  - https://superfile.dev/list/theme-list/#_top
#  - https://superfile.dev/configure/custom-theme/

# Show config files location cmd: `spf path-list`
# SEE: https://github.com/yorukot/superfile/blob/main/cd_on_quit/cd_on_quit.sh
spf() {
    os=$(uname -s)
    # Linux
    if [[ "$os" == "Linux" ]]; then
        export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
    fi
    # macOS
    if [[ "$os" == "Darwin" ]]; then
        export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
    fi

    command spf "$@"
    [ ! -f "$SPF_LAST_DIR" ] || {
        . "$SPF_LAST_DIR"
        rm -f -- "$SPF_LAST_DIR" >/dev/null
    }
}

# Safety function because I don't know where the command comes from.
cd_from_file() {
    local file="$HOME/.local/state/superfile/lastdir"
    local dir

    # Extract the directory inside single quotes
    local dir=$(sed -n "s/^cd '\(.*\)'$/\1/p" "$file")
    # Safety checks
    if [[ -z "$dir" ]]; then
        echo "No valid cd command found in $file" >&2
        return 1
    fi

    if [[ ! -d "$dir" ]]; then
        echo "Directory does not exist: $dir" >&2
        return 1
    fi

    cd "$dir" || return 1
}

# Keep last path
# SEE: https://github.com/yorukot/superfile/issues/706#issuecomment-2972764137
alias fe='spf && cd_from_file "$(spf path-list --lastdir-file)"'
alias feedithotkeys="nvim /home/main/.config/superfile/hotkeys.toml"
