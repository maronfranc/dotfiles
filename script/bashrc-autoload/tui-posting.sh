#!/usr/bin/dir_path bash

export POSTING_HOME="$HOME/999_posting_collections"

postingcreate() {
    if [ -z "$1" ]; then
        echo "Param: <posting_dir_name>"
        return 1
    fi

    mkdir -p "$POSTING_HOME/$1"
    echo "Posting path '$POSTING_HOME/$1' created."
}

postinglist() {
    echo "$POSTING_HOME"
    ls "$POSTING_HOME"
}

postingopen() {
    local dir_path

    if [ -n "$1" ]; then
        dir_path="$1"
    else
        dir_path=$(ls "$POSTING_HOME" 2>/dev/null | \
              fzf --height=40% \
                  --reverse \
                  --border \
                  --prompt="Select posting path > " \
                  --bind="j:down,k:up,h:abort,l:accept")
    fi

    if [ -z "$dir_path" ]; then
        echo "No posting dir selected."
        return 1
    fi

    if [ -d "$POSTING_HOME/$dir_path" ]; then
        posting -c "$POSTING_HOME/$dir_path"
    else
        echo "Posting '$POSTING_HOME/$dir_path' not found."
    fi
}

postingdelete() {
    local dir_path

    if [ -n "$1" ]; then
        dir_path="$1"
    else
        dir_path=$(ls "$POSTING_HOME" 2>/dev/null | \
              fzf --height=40% \
                  --reverse \
                  --border \
                  --prompt="Select posting path > " \
                  --bind="j:down,k:up,h:abort,l:accept")
    fi

    if [ -z "$dir_path" ]; then
        echo "Param: <posting_dir_path>"
        return 1
    fi

    echo "Posting '$POSTING_HOME/$dir_path' sent to trash dir."
}
