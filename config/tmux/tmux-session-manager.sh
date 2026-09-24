#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
umask 077

PROGRAM_NAME=${0##*/}
STATE_HOME=${XDG_STATE_HOME:-"${HOME:-}/.local/state"}
SNAPSHOT_FILE=${TMUX_SESSION_SNAPSHOT_FILE:-"${STATE_HOME}/tmux/snapshots.json"}
LOCK_FILE="${SNAPSHOT_FILE}.lock"
EMPTY_STORE='{"schema":1,"snapshots":[]}'

TABLE_BORDER_COLOR=$'\033[36m'
TABLE_HEADER_COLOR=$'\033[1;97m'
TABLE_NAME_COLOR=$'\033[1;36m'
TABLE_SESSION_COLOR=$'\033[32m'
TABLE_COUNT_COLOR=$'\033[33m'
TABLE_DATE_COLOR=$'\033[2;37m'
TABLE_STATUS_RUNNING_COLOR=$'\033[32m'
TABLE_STATUS_STOPPED_COLOR=$'\033[2;37m'
TABLE_RESET=$'\033[0m'

TEMP_FILES=()
TEMP_SESSION_ID=
LOCK_FD=
ASSUME_YES=0
ALL_SNAPSHOTS=0
PARSED_ARGUMENTS=()
TMUX_RUNNING_SESSIONS=()

cleanup() {
    local file

    for file in "${TEMP_FILES[@]}"; do
        [[ -n "$file" ]] && rm -f -- "$file"
    done

    if [[ -n "$TEMP_SESSION_ID" ]]; then
        tmux_cmd kill-session -t "$TEMP_SESSION_ID" >/dev/null 2>&1 || true
    fi

    if [[ -n "$LOCK_FD" ]]; then
        exec {LOCK_FD}>&- || true
    fi
}

trap cleanup EXIT

usage() {
    printf '%s\n' "Usage: ${PROGRAM_NAME} [<new|save|restore|delete|stop|list|export|import>] [name-or-id] [--all] [--yes]"
}

notify() {
    local message="[Tmux session] $1"
    local client=

    if [[ -n "${TMUX_SESSION_MANAGER_CLIENT:-}" ]]; then
        client=$TMUX_SESSION_MANAGER_CLIENT
    else
        client=$(tmux_client_name 2>/dev/null) || client=
    fi

    if [[ -n "$client" ]]; then
        if ! tmux_cmd display-message -c "$client" "$(tmux_escape_format "$message")" >/dev/null 2>&1; then
            printf '%s\n' "$message" >&2
        fi
    elif ! tmux_cmd display-message "$(tmux_escape_format "$message")" >/dev/null 2>&1; then
        printf '%s\n' "$message" >&2
    fi
}

die() {
    local message=$1

    notify "${PROGRAM_NAME}: ${message}"
    printf '%s: %s\n' "$PROGRAM_NAME" "$message" >&2
    exit 1
}

require_command() {
    local command_name=$1

    command -v "$command_name" >/dev/null 2>&1 || die "required command not found: ${command_name}"
}

inside_tmux() {
    [[ -n "${TMUX:-}" || -n "${TMUX_PANE:-}" || -n "${TMUX_SESSION_MANAGER_CLIENT:-}" || -n "${TMUX_SESSION_MANAGER_SOURCE_PANE:-}" ]]
}

require_outside_tmux() {
    if inside_tmux; then
        die "this command must be run from a terminal outside tmux"
    fi
}

tmux_client_name() {
    if [[ -n "${TMUX_SESSION_MANAGER_CLIENT:-}" ]]; then
        printf '%s' "$TMUX_SESSION_MANAGER_CLIENT"
        return 0
    fi

    local pane=${TMUX_SESSION_MANAGER_SOURCE_PANE:-${TMUX_PANE:-}}
    [[ -n "$pane" ]] || return 1
    tmux_cmd display-message -p -t "$pane" '#{client_name}'
}

switch_client() {
    local target=$1
    local client

    client=$(tmux_client_name) || die "unable to determine the current tmux client"
    [[ -n "$client" ]] || die "unable to determine the current tmux client"
    tmux_cmd switch-client -c "$client" -t "$target" || die "unable to switch to the selected tmux session"
}

activate_session() {
    local target=$1

    if inside_tmux; then
        switch_client "$target"
    else
        tmux_cmd attach-session -t "$target" || die "unable to attach tmux session"
    fi
}

tmux_cmd() {
    if [[ -n "${TMUX_SESSION_MANAGER_SOCKET:-}" ]]; then
        TMUX= tmux -S "${TMUX_SESSION_MANAGER_SOCKET}" "$@"
    else
        tmux "$@"
    fi
}

tmux_value() {
    local target=$1
    local format=$2

    tmux_cmd display-message -p -t "$target" "$format"
}

tmux_escape_format() {
    local value=$1

    value=${value//\#/\#\#}
    printf '%s' "$value"
}

load_running_sessions() {
    local name

    TMUX_RUNNING_SESSIONS=()
    command -v tmux >/dev/null 2>&1 || return 0

    while IFS= read -r name; do
        if [[ -n "$name" ]]; then
            TMUX_RUNNING_SESSIONS+=("$name")
        fi
    done < <(tmux_cmd list-sessions -F '#{session_name}' 2>/dev/null) || true
}

session_running() {
    local name=$1
    local running

    [[ -n "$name" ]] || return 1
    for running in "${TMUX_RUNNING_SESSIONS[@]}"; do
        if [[ "$running" == "$name" ]]; then
            return 0
        fi
    done
    return 1
}

json_number() {
    local value=$1

    if [[ "$value" =~ ^-?[0-9]+$ ]]; then
        printf '%s' "$value"
    else
        printf 'null'
    fi
}

json_boolean() {
    local value=$1

    if [[ "$value" == "1" ]]; then
        printf 'true'
    else
        printf 'false'
    fi
}

new_temp_file() {
    local path

    path=$(mktemp "${TMPDIR:-/tmp}/tmux-session-manager.XXXXXX") || die "unable to create temporary file"
    TEMP_FILES+=("$path")
    NEW_TEMP_FILE=$path
}

read_store_to_file() {
    local target=$1

    if [[ -e "$SNAPSHOT_FILE" ]]; then
        [[ -f "$SNAPSHOT_FILE" ]] || die "snapshot path is not a regular file: ${SNAPSHOT_FILE}"
        if ! jq -e 'if (type == "object" and .schema == 1 and ((.snapshots | type) == "array")) then . else error("invalid snapshot database") end' "$SNAPSHOT_FILE" > "$target"; then
            die "invalid snapshot database: ${SNAPSHOT_FILE}"
        fi
    else
        printf '%s\n' "$EMPTY_STORE" > "$target"
    fi
}

read_backup_to_file() {
    local source=$1
    local target=$2

    [[ -f "$source" ]] || die "backup file not found: ${source}"
    if ! jq -e 'if (type == "object" and .schema == 1 and ((.snapshots | type) == "array")) then . else error("invalid snapshot backup") end' "$source" > "$target"; then
        die "invalid snapshot backup: ${source}"
    fi
}

validate_snapshot_document() {
    local file=$1

    jq -e '
        (type == "object" and .schema == 1 and ((.snapshots | type) == "array")) and
        all(.snapshots[];
            (.id | type == "string" and length > 0) and
            (.name | type == "string") and
            (.session.name | type == "string" and length > 0) and
            (.session.windows | type == "array" and length > 0) and
            all(.session.windows[];
                (.name | type == "string") and
                (.panes | type == "array" and length > 0) and
                all(.panes[]; (.path | type == "string"))
            )
        )
    ' "$file" >/dev/null
}

write_store_file() {
    local target=$1
    local directory temporary

    directory=$(dirname -- "$target")
    mkdir -p -- "$directory" || die "unable to create snapshot directory: ${directory}"
    temporary=$(mktemp "${directory}/.snapshots.XXXXXX") || die "unable to create temporary snapshot file"

    if ! jq -e 'if (type == "object" and .schema == 1 and ((.snapshots | type) == "array")) then . else error("invalid snapshot database") end' > "$temporary"; then
        rm -f -- "$temporary"
        die "refusing to write invalid snapshot database"
    fi

    chmod 600 "$temporary" || {
        rm -f -- "$temporary"
        die "unable to set snapshot permissions"
    }

    if ! mv -f -- "$temporary" "$target"; then
        rm -f -- "$temporary"
        die "unable to replace snapshot database"
    fi
}

write_store() {
    write_store_file "$SNAPSHOT_FILE"
}

acquire_lock() {
    local directory

    require_command flock
    directory=$(dirname -- "$LOCK_FILE")
    mkdir -p -- "$directory" || die "unable to create lock directory: ${directory}"
    exec {LOCK_FD}>"$LOCK_FILE" || die "unable to open snapshot lock"
    flock -x "$LOCK_FD" || die "unable to acquire snapshot lock"
}

validate_snapshot_name() {
    local name=$1

    [[ -n "$name" ]] || die "snapshot name cannot be empty"
    ((${#name} <= 128)) || die "snapshot name is too long"
    [[ ! "$name" =~ [[:cntrl:]] ]] || die "snapshot name cannot contain control characters"
}

confirm() {
    local prompt=$1
    local answer

    if ((ASSUME_YES)); then
        return 0
    fi

    printf '%s [y/N] ' "$prompt"
    IFS= read -r answer || return 1
    [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

pick_command() {
    local selected
    local -a commands

    require_command fzf
    if inside_tmux; then
        commands=(save restore delete stop list export import)
    else
        commands=(restore delete stop new list export import)
    fi

    if ! selected=$(printf '%s\n' "${commands[@]}" | fzf --height=80% --border --reverse --pointer='▶' --prompt='Command: ' --bind='j:down,k:up,h:abort,l:accept'); then
        return 1
    fi

    [[ -n "$selected" ]] || return 1
    printf '%s' "$selected"
}

pick_snapshot_ids() {
    local prompt=$1
    local multi=${2:-0}
    local store_file=${3:-}
    local selected row index value_length value_index color
    local -a rows=()
    local -a values=()
    local -a widths=(0 0 0 0 0 0)
    local -a fzf_options=(
        --ansi
        --height=80%
        --border
        --reverse
        --delimiter=$'\t'
        --with-nth=2..
        --pointer='▶'
        --prompt="$prompt"
        --bind='j:down,k:up,h:abort,l:accept'
    )
    local -a picker_colors=(
        "$TABLE_NAME_COLOR"
        "$TABLE_SESSION_COLOR"
        "$TABLE_COUNT_COLOR"
        "$TABLE_COUNT_COLOR"
        "$TABLE_DATE_COLOR"
        "$TABLE_STATUS_RUNNING_COLOR"
    )

    require_command jq
    require_command fzf
    if [[ -z "$store_file" ]]; then
        new_temp_file
        store_file=$NEW_TEMP_FILE
        read_store_to_file "$store_file"
    fi
    if ((multi)); then
        fzf_options+=(--multi)
    fi

    if ! jq -e '.snapshots | length > 0' "$store_file" >/dev/null; then
        notify "No saved tmux sessions"
        return 1
    fi

    mapfile -t rows < <(
        jq -r '.snapshots | sort_by(.saved_at) | reverse[] | [
            .id,
            .name,
            .session.name,
            (.session.windows | length),
            ([.session.windows[].panes | length] | add // 0),
            (.saved_at | if type == "string" then (sub("T"; " ") | .[0:16]) else tostring end)
        ] | @tsv' "$store_file"
    )

    load_running_sessions
    for index in "${!rows[@]}"; do
        IFS=$'\t' read -r -a values <<< "${rows[$index]}"
        if session_running "${values[2]}"; then
            rows[$index]+=$'\t'"running"
        else
            rows[$index]+=$'\t'"stopped"
        fi
    done

    for row in "${rows[@]}"; do
        IFS=$'\t' read -r -a values <<< "$row"
        for index in 0 1 2 3 4 5; do
            value_index=$((index + 1))
            value_length=${#values[value_index]}
            if ((value_length > widths[index])); then
                widths[index]=$value_length
            fi
        done
    done

    if ! selected=$(
        for row in "${rows[@]}"; do
            IFS=$'\t' read -r -a values <<< "$row"
            printf '%s' "${values[0]}"
            for index in 0 1 2 3 4 5; do
                value_index=$((index + 1))
                color=${picker_colors[index]}
                if ((index == 5)); then
                    if [[ "${values[value_index]}" == "running" ]]; then
                        color=$TABLE_STATUS_RUNNING_COLOR
                    else
                        color=$TABLE_STATUS_STOPPED_COLOR
                    fi
                fi
                printf '\t%s%-*s%s' \
                    "$color" "${widths[index]}" "${values[value_index]}" \
                    "$TABLE_RESET"
            done
            printf '\n'
        done |
        fzf "${fzf_options[@]}"
    ); then
        return 1
    fi

    [[ -n "$selected" ]] || return 1
    while IFS= read -r row; do
        [[ -n "$row" ]] || continue
        printf '%s\n' "${row%%$'\t'*}"
    done <<< "$selected"
}

pick_snapshot_id() {
    local prompt=$1
    local store_file=${2:-}
    local selected

    selected=$(pick_snapshot_ids "$prompt" 0 "$store_file") || return 1
    printf '%s' "${selected%%$'\n'*}"
}

pick_running_session() {
    local prompt=$1
    local selected row index value_length name
    local -a rows=()
    local -a values=()
    local -a widths=(0 0 0 0)
    local -a picker_colors=(
        "$TABLE_SESSION_COLOR"
        "$TABLE_COUNT_COLOR"
        "$TABLE_COUNT_COLOR"
        "$TABLE_COUNT_COLOR"
    )
    local -A pane_counts=()

    require_command tmux
    require_command fzf

    while IFS=$'\t' read -r name _; do
        [[ -n "$name" ]] || continue
        pane_counts[$name]=$(( ${pane_counts[$name]:-0} + 1 ))
    done < <(tmux_cmd list-panes -a -F $'#{session_name}\t#{pane_id}' 2>/dev/null)

    while IFS=$'\t' read -r name windows attached; do
        [[ -n "$name" ]] || continue
        [[ ! "$name" =~ [[:cntrl:]] ]] || continue
        rows+=("$name"$'\t'"$windows"$'\t'"${pane_counts[$name]:-0}"$'\t'"$attached")
    done < <(tmux_cmd list-sessions -F $'#{session_name}\t#{session_windows}\t#{session_attached}' 2>/dev/null)

    if ((${#rows[@]} == 0)); then
        notify "No running tmux sessions"
        return 1
    fi

    for row in "${rows[@]}"; do
        IFS=$'\t' read -r -a values <<< "$row"
        for index in 0 1 2 3; do
            value_length=${#values[index]}
            if ((value_length > widths[index])); then
                widths[index]=$value_length
            fi
        done
    done

    if ! selected=$(
        for row in "${rows[@]}"; do
            IFS=$'\t' read -r -a values <<< "$row"
            printf '%s' "${values[0]}"
            for index in 0 1 2 3; do
                printf '\t%s%-*s%s' \
                    "${picker_colors[index]}" "${widths[index]}" "${values[index]}" \
                    "$TABLE_RESET"
            done
            printf '\n'
        done |
        fzf --ansi --height=80% --border --reverse --delimiter=$'\t' --with-nth=2.. --pointer='▶' --prompt="$prompt" --bind='j:down,k:up,h:abort,l:accept'
    ); then
        return 1
    fi

    [[ -n "$selected" ]] || return 1
    printf '%s' "${selected%%$'\t'*}"
}

pick_backup_file() {
    local prompt=$1
    local entry file mtime size base selected
    local size_width=0
    local base_width=0
    local -a files=()
    local -a entries=()
    local -a rows=()

    require_command jq
    require_command fzf
    require_command stat

    shopt -s nullglob
    files=(*.json)
    shopt -u nullglob

    for file in "${files[@]}"; do
        [[ -f "$file" ]] || continue
        jq -e 'type == "object" and .schema == 1 and ((.snapshots | type) == "array")' "$file" >/dev/null 2>&1 || continue
        mtime=$(date -u -r "$file" '+%Y-%m-%d %H:%M' 2>/dev/null) || continue
        size=$(stat -c '%s' "$file" 2>/dev/null) || continue
        base=${file##*/}
        entries+=("${mtime}"$'\t'"${size}"$'\t'"${base}"$'\t'"${file}")
    done

    if ((${#entries[@]} == 0)); then
        notify "No snapshot backups in ${PWD}"
        return 1
    fi

    mapfile -t entries < <(printf '%s\n' "${entries[@]}" | sort -r)

    for entry in "${entries[@]}"; do
        IFS=$'\t' read -r mtime size base file <<< "$entry"
        rows+=("$file"$'\t'"$mtime"$'\t'"$size"$'\t'"$base")
        if ((${#size} > size_width)); then
            size_width=${#size}
        fi
        if ((${#base} > base_width)); then
            base_width=${#base}
        fi
    done

    if ! selected=$(
        for entry in "${rows[@]}"; do
            IFS=$'\t' read -r file mtime size base <<< "$entry"
            printf '%s\t%s\t%*s\t%*s\n' \
                "$file" "$mtime" "$size_width" "$size" "$base_width" "$base"
        done |
        fzf --height=80% --border --reverse --delimiter=$'\t' --with-nth=2.. \
            --pointer='▶' --prompt="$prompt" --bind='j:down,k:up,h:abort,l:accept' \
            --preview='jq -r "[.snapshots[].name] | @tsv" {1}'
    ); then
        return 1
    fi

    [[ -n "$selected" ]] || return 1
    printf '%s' "${selected%%$'\t'*}"
}

capture_snapshot() {
    local output_file=$1
    local current_pane session_id session_name saved_at tmux_version current_window
    local picker_window_id=
    local source_active_window=${TMUX_SESSION_MANAGER_SOURCE_ACTIVE_WINDOW:-}
    local window_id window_name window_index window_active window_layout
    local window_width window_height window_zoomed automatic_rename
    local pane_id pane_index pane_path pane_start_path pane_title
    local pane_active pane_width pane_height pane_command
    local windows_file panes_file
    local -a window_ids pane_ids
    local window_count pane_count

    current_pane=${TMUX_SESSION_MANAGER_SOURCE_PANE:-${TMUX_PANE:-}}
    if [[ -z "$current_pane" ]]; then
        current_pane=$(tmux_cmd display-message -p '#{pane_id}') || die "unable to determine the current tmux pane"
    fi

    session_id=$(tmux_value "$current_pane" '#{session_id}') || die "unable to determine the current tmux session"
    session_name=$(tmux_value "$session_id" '#{session_name}') || die "unable to read the current tmux session name"
    [[ -n "$session_name" ]] || die "the current tmux session has no name"
    [[ ! "$session_name" =~ [[:cntrl:]] ]] || die "the current tmux session name contains control characters"

    if [[ -n "${TMUX_SESSION_MANAGER_PICKER:-}" && -n "${TMUX_PANE:-}" ]]; then
        picker_window_id=$(tmux_value "$TMUX_PANE" '#{window_id}') || die "unable to determine the picker window"
    fi

    mapfile -t window_ids < <(tmux_cmd list-windows -t "$session_id" -F '#{window_id}')
    if [[ -n "$picker_window_id" ]]; then
        local -a filtered_window_ids=()
        for window_id in "${window_ids[@]}"; do
            if [[ "$window_id" != "$picker_window_id" ]]; then
                filtered_window_ids+=("$window_id")
            fi
        done
        window_ids=("${filtered_window_ids[@]}")
    fi
    window_count=${#window_ids[@]}
    ((window_count > 0)) || die "the current tmux session has no windows"

    new_temp_file
    windows_file=$NEW_TEMP_FILE
    : > "$windows_file"
    current_window=$(json_number 1)

    for window_id in "${window_ids[@]}"; do
        window_name=$(tmux_value "$window_id" '#{window_name}') || die "unable to read window name"
        window_index=$(tmux_value "$window_id" '#{window_index}') || die "unable to read window index"
        window_active=$(tmux_value "$window_id" '#{window_active}') || die "unable to read window state"
        window_layout=$(tmux_value "$window_id" '#{window_layout}') || die "unable to read window layout"
        window_width=$(tmux_value "$window_id" '#{window_width}') || die "unable to read window width"
        window_height=$(tmux_value "$window_id" '#{window_height}') || die "unable to read window height"
        window_zoomed=$(tmux_value "$window_id" '#{window_zoomed_flag}') || die "unable to read window zoom state"
        if ! automatic_rename=$(tmux_cmd show-window-options -t "$window_id" -v automatic-rename 2>/dev/null); then
            automatic_rename=off
        fi

        if [[ -n "$source_active_window" && "$window_id" == "$source_active_window" ]]; then
            window_active=1
            current_window=$(json_number "$window_index")
        elif [[ -n "$picker_window_id" ]]; then
            window_active=0
        elif [[ "$window_active" == "1" ]]; then
            current_window=$(json_number "$window_index")
        fi

        mapfile -t pane_ids < <(tmux_cmd list-panes -t "$window_id" -F '#{pane_id}')
        pane_count=${#pane_ids[@]}
        ((pane_count > 0)) || die "window ${window_id} has no panes"

        new_temp_file
        panes_file=$NEW_TEMP_FILE
        : > "$panes_file"
        for pane_id in "${pane_ids[@]}"; do
            pane_index=$(tmux_value "$pane_id" '#{pane_index}') || die "unable to read pane index"
            pane_path=$(tmux_value "$pane_id" '#{pane_current_path}') || die "unable to read pane path"
            pane_start_path=$(tmux_value "$pane_id" '#{pane_start_path}') || pane_start_path=$pane_path
            pane_title=$(tmux_value "$pane_id" '#{pane_title}') || pane_title=
            pane_active=$(tmux_value "$pane_id" '#{pane_active}') || die "unable to read pane state"
            pane_width=$(tmux_value "$pane_id" '#{pane_width}') || die "unable to read pane width"
            pane_height=$(tmux_value "$pane_id" '#{pane_height}') || die "unable to read pane height"
            pane_command=$(tmux_value "$pane_id" '#{pane_current_command}') || pane_command=

            jq -n \
                --arg source_id "$pane_id" \
                --argjson index "$(json_number "$pane_index")" \
                --arg path "$pane_path" \
                --arg start_path "$pane_start_path" \
                --arg title "$pane_title" \
                --argjson active "$(json_boolean "$pane_active")" \
                --argjson width "$(json_number "$pane_width")" \
                --argjson height "$(json_number "$pane_height")" \
                --arg command "$pane_command" \
                '{source_id: $source_id, index: $index, path: $path, start_path: $start_path, title: $title, active: $active, width: $width, height: $height, command: $command}' \
                >> "$panes_file"
        done

        jq -n \
            --arg source_id "$window_id" \
            --arg name "$window_name" \
            --argjson index "$(json_number "$window_index")" \
            --argjson active "$(json_boolean "$window_active")" \
            --arg layout "$window_layout" \
            --argjson width "$(json_number "$window_width")" \
            --argjson height "$(json_number "$window_height")" \
            --argjson zoomed "$(json_boolean "$window_zoomed")" \
            --arg automatic_rename "$automatic_rename" \
            --slurpfile panes "$panes_file" \
            '{source_id: $source_id, name: $name, index: $index, active: $active, layout: $layout, width: $width, height: $height, zoomed: $zoomed, automatic_rename: $automatic_rename, panes: $panes}' \
            >> "$windows_file"
    done

    saved_at=$(date -u +%Y-%m-%dT%H:%M:%SZ) || die "unable to read current time"
    tmux_version=$(tmux_cmd -V) || die "unable to read tmux version"
    tmux_version=${tmux_version##* }

    jq -n \
        --arg id "$(date -u +%Y%m%dT%H%M%S%N)-$$-$RANDOM" \
        --arg name "" \
        --arg saved_at "$saved_at" \
        --arg tmux_version "$tmux_version" \
        --arg session_name "$session_name" \
        --argjson current_window "$current_window" \
        --slurpfile windows "$windows_file" \
        '{id: $id, name: $name, saved_at: $saved_at, tmux_version: $tmux_version, session: {name: $session_name, current_window: $current_window, windows: $windows}}' \
        > "$output_file"
}

new_session() {
    local target
    local consonants="bcdfghjklmnpqrstvwxyz"

    require_command tmux
    require_outside_tmux

    read -r -p "Session name (empty to random): " target
    if [[ -z "$target" ]]; then
        target="session-"
        for _ in {1..5}; do
            target+="${consonants:RANDOM % ${#consonants}:1}"
        done
    fi
    echo -ne "\033]0;  [${target}] Tmux session\007"
    if ! tmux_cmd has-session -t "=${target}" >/dev/null 2>&1; then
        tmux_cmd new-session -s "$target" || die "unable to create tmux session '${target}'"
        return
    fi

    tmux_cmd attach-session -t "=${target}" || die "unable to attach existing tmux session '${target}'"
}

save_snapshot() {
    local requested_name=${1:-}
    local capture_file store_file updated_file
    local name

    require_command tmux
    require_command jq
    require_command flock
    require_command date

    new_temp_file
    capture_file=$NEW_TEMP_FILE
    capture_snapshot "$capture_file"
    if [[ -n "$requested_name" ]]; then
        name=$requested_name
    else
        name=$(jq -er '.session.name' "$capture_file") || die "unable to determine the current tmux session name"
    fi
    validate_snapshot_name "$name"

    jq --arg name "$name" '.name = $name' "$capture_file" > "${capture_file}.updated" || die "unable to prepare snapshot"
    TEMP_FILES+=("${capture_file}.updated")
    capture_file="${capture_file}.updated"

    acquire_lock
    new_temp_file
    store_file=$NEW_TEMP_FILE
    read_store_to_file "$store_file"

    new_temp_file
    updated_file=$NEW_TEMP_FILE
    jq --arg name "$name" --slurpfile snapshot "$capture_file" '.snapshots |= (map(select(.name != $name)) + [$snapshot[0]])' "$store_file" > "$updated_file" || die "unable to update snapshot database"
    write_store < "$updated_file"
    notify "Saved tmux session '${name}'"
}

restore_snapshot_from_id() {
    local snapshot_id=$1
    local store_file snapshot_file session_name
    local temp_name temp_session_id first_window_name first_path
    local first_window_object first_window_id
    local window_object window_name window_path window_layout window_active window_zoomed
    local live_window_id first_pane_id pane_object pane_path pane_title pane_active
    local live_pane_id active_pane_id active_window_id
    local window_count pane_count window_number pane_number
    local -a window_objects pane_objects initial_windows initial_panes

    require_command tmux
    require_command jq

    new_temp_file
    store_file=$NEW_TEMP_FILE
    read_store_to_file "$store_file"
    new_temp_file
    snapshot_file=$NEW_TEMP_FILE
    if ! jq -c --arg id "$snapshot_id" '.snapshots[] | select(.id == $id)' "$store_file" > "$snapshot_file"; then
        die "unable to read saved snapshot"
    fi
    [[ -s "$snapshot_file" ]] || die "saved snapshot no longer exists: ${snapshot_id}"

    if ! jq -e '
        (.session.name | type == "string" and length > 0) and
        (.session.windows | type == "array" and length > 0) and
        all(.session.windows[];
            (.name | type == "string") and
            (.panes | type == "array" and length > 0) and
            all(.panes[]; (.path | type == "string"))
        )
    ' "$snapshot_file" >/dev/null; then
        die "saved snapshot has an invalid structure"
    fi

    session_name=$(jq -r '.session.name' "$snapshot_file")
    [[ ! "$session_name" =~ [[:cntrl:]] ]] || die "saved session name contains control characters"
    if inside_tmux; then
        save_snapshot
    fi
    if tmux_cmd has-session -t "=${session_name}" >/dev/null 2>&1; then
        echo -ne "\033]0;  [${session_name}] Tmux session\007"
        activate_session "=${session_name}"
        notify "Attached existing tmux session '${session_name}'"
        return 0
    fi

    first_window_object=$(jq -c '.session.windows[0]' "$snapshot_file")
    first_window_name=$(jq -r '.name' <<< "$first_window_object")
    first_path=$(jq -r '.panes[0].path' <<< "$first_window_object")
    if [[ ! -d "$first_path" ]]; then
        first_path="${HOME:-/}"
    fi

    temp_name="tmux-snapshot-restore-$$-$(date +%s%N)"
    if ! temp_session_id=$(tmux_cmd new-session -d -s "$temp_name" -n "$(tmux_escape_format "$first_window_name")" -c "$first_path" -P -F '#{session_id}'); then
        die "unable to create temporary tmux session"
    fi
    TEMP_SESSION_ID=$temp_session_id

    mapfile -t initial_windows < <(tmux_cmd list-windows -t "$temp_session_id" -F '#{window_id}')
    ((${#initial_windows[@]} > 0)) || die "temporary tmux session has no window"
    first_window_id=${initial_windows[0]}

    mapfile -t window_objects < <(jq -c '.session.windows[]' "$snapshot_file")
    window_count=${#window_objects[@]}
    ((window_count > 0)) || die "saved snapshot has no windows"

    active_window_id=$first_window_id
    window_number=0
    for window_object in "${window_objects[@]}"; do
        window_name=$(jq -r '.name' <<< "$window_object")
        window_path=$(jq -r '.panes[0].path' <<< "$window_object")
        window_layout=$(jq -r '.layout // ""' <<< "$window_object")
        window_active=$(jq -r 'if .active then "1" else "0" end' <<< "$window_object")
        window_zoomed=$(jq -r 'if .zoomed then "1" else "0" end' <<< "$window_object")
        if [[ ! -d "$window_path" ]]; then
            window_path="${HOME:-/}"
        fi

        if ((window_number == 0)); then
            live_window_id=$first_window_id
        elif ! live_window_id=$(tmux_cmd new-window -d -P -F '#{window_id}' -t "$temp_session_id" -n "$(tmux_escape_format "$window_name")" -c "$window_path"); then
            die "unable to create tmux window"
        fi

        tmux_cmd rename-window -t "$live_window_id" "$(tmux_escape_format "$window_name")" || die "unable to rename tmux window"

        mapfile -t pane_objects < <(jq -c '.panes[]' <<< "$window_object")
        pane_count=${#pane_objects[@]}
        ((pane_count > 0)) || die "saved window has no panes"

        mapfile -t initial_panes < <(tmux_cmd list-panes -t "$live_window_id" -F '#{pane_id}')
        ((${#initial_panes[@]} > 0)) || die "restored window has no pane"
        first_pane_id=${initial_panes[0]}
        active_pane_id=$first_pane_id
        pane_number=0

        for pane_object in "${pane_objects[@]}"; do
            pane_path=$(jq -r '.path' <<< "$pane_object")
            pane_title=$(jq -r '.title // ""' <<< "$pane_object")
            pane_active=$(jq -r 'if .active then "1" else "0" end' <<< "$pane_object")
            if [[ ! -d "$pane_path" ]]; then
                pane_path="${HOME:-/}"
            fi

            if ((pane_number == 0)); then
                live_pane_id=$first_pane_id
            elif ! live_pane_id=$(tmux_cmd split-window -d -P -F '#{pane_id}' -t "$first_pane_id" -c "$pane_path"); then
                die "unable to create tmux pane"
            fi

            tmux_cmd select-pane -t "$live_pane_id" -T "$(tmux_escape_format "$pane_title")" || die "unable to set pane title"
            if [[ "$pane_active" == "1" ]]; then
                active_pane_id=$live_pane_id
            fi
            pane_number=$((pane_number + 1))
        done

        if [[ -n "$window_layout" ]]; then
            tmux_cmd select-layout -t "$first_pane_id" "$window_layout" || die "unable to apply saved tmux layout"
        fi
        tmux_cmd select-pane -t "$active_pane_id" || die "unable to select active tmux pane"
        if [[ "$window_zoomed" == "1" ]]; then
            tmux_cmd resize-pane -Z -t "$active_pane_id" || true
        fi
        if [[ "$window_active" == "1" ]]; then
            active_window_id=$live_window_id
        fi
        window_number=$((window_number + 1))
    done

    tmux_cmd select-window -t "$active_window_id" || die "unable to select active tmux window"
    if tmux_cmd has-session -t "=${session_name}" >/dev/null 2>&1; then
        echo -ne "\033]0;  [${session_name}] Tmux session\007"
        activate_session "=${session_name}"
        notify "Attached existing tmux session '${session_name}'"
        return 0
    fi
    tmux_cmd rename-session -t "$temp_session_id" "$(tmux_escape_format "$session_name")" || die "unable to name restored tmux session"
    echo -ne "\033]0;  [${session_name}] Tmux session\007"
    activate_session "$temp_session_id"
    TEMP_SESSION_ID=
    notify "Restored tmux session '${session_name}'"
}

restore_snapshot() {
    local snapshot_id=${1:-}

    if [[ -z "$snapshot_id" ]]; then
        snapshot_id=$(pick_snapshot_id "Restore tmux session: ") || return 0
    fi
    restore_snapshot_from_id "$snapshot_id"
}

delete_snapshot() {
    local snapshot_id=${1:-}
    local store_file snapshot_name updated_file

    require_command jq
    if [[ -z "$snapshot_id" ]]; then
        snapshot_id=$(pick_snapshot_id "Delete tmux session: ") || return 0
    fi

    new_temp_file
    store_file=$NEW_TEMP_FILE
    read_store_to_file "$store_file"
    snapshot_name=$(jq -r --arg id "$snapshot_id" '.snapshots[] | select(.id == $id) | .name' "$store_file")
    [[ -n "$snapshot_name" ]] || {
        notify "Saved tmux session no longer exists"
        return 0
    }

    confirm "Delete saved tmux session '${snapshot_name}'?" || return 0

    acquire_lock
    new_temp_file
    store_file=$NEW_TEMP_FILE
    read_store_to_file "$store_file"
    if ! jq -e --arg id "$snapshot_id" '.snapshots[] | select(.id == $id)' "$store_file" >/dev/null; then
        notify "Saved tmux session no longer exists"
        return 0
    fi

    new_temp_file
    updated_file=$NEW_TEMP_FILE
    jq --arg id "$snapshot_id" '.snapshots |= map(select(.id != $id))' "$store_file" > "$updated_file" || die "unable to update snapshot database"
    write_store < "$updated_file"
    notify "Deleted tmux session '${snapshot_name}'"
}

export_snapshots() {
    local output_path=${1:-}
    local store_file snapshot_count timestamp

    require_command jq
    require_command date

    if [[ -z "$output_path" ]]; then
        timestamp=$(date -u +%Y%m%dT%H%M%SZ) || die "unable to read current time"
        output_path="tmux-session-snapshots-${timestamp}.json"
    fi
    [[ "$output_path" != "$SNAPSHOT_FILE" ]] || die "refusing to overwrite the snapshot database"
    if [[ -e "$output_path" ]]; then
        confirm "Overwrite backup file '${output_path}'?" || return 0
    fi

    new_temp_file
    store_file=$NEW_TEMP_FILE
    read_store_to_file "$store_file"

    snapshot_count=$(jq -r '.snapshots | length' "$store_file") || die "unable to read snapshot database"
    if ((snapshot_count == 0)); then
        notify "No saved tmux sessions"
        return 0
    fi
    validate_snapshot_document "$store_file" || die "refusing to export invalid snapshot data"

    write_store_file "$output_path" < "$store_file"
    notify "Exported ${snapshot_count} snapshot(s) to '${output_path}'"
}

import_snapshots() {
    local backup_path=${1:-}
    local backup_file store_file updated_file selected ids_json
    local snapshot_count collision_count incoming_count

    require_command jq

    if [[ -z "$backup_path" ]]; then
        backup_path=$(pick_backup_file "Import backup: ") || return 0
    fi

    new_temp_file
    backup_file=$NEW_TEMP_FILE
    read_backup_to_file "$backup_path" "$backup_file"
    validate_snapshot_document "$backup_file" || die "invalid snapshot backup: ${backup_path}"

    if ! jq -e '.snapshots | length > 0' "$backup_file" >/dev/null; then
        notify "Backup file contains no snapshots"
        return 0
    fi

    if ((ALL_SNAPSHOTS)); then
        ids_json=$(jq -c '[.snapshots[].id]' "$backup_file") || die "unable to read snapshots from backup"
    else
        selected=$(pick_snapshot_ids "Import tmux session(s): " 1 "$backup_file") || return 0
        [[ -n "$selected" ]] || return 0
        ids_json=$(printf '%s\n' "$selected" | jq -R -s 'split("\n") | map(select(length > 0))') || die "unable to read selected snapshots"
    fi
    incoming_count=$(jq -r 'length' <<< "$ids_json") || die "unable to read snapshots to import"

    new_temp_file
    store_file=$NEW_TEMP_FILE
    read_store_to_file "$store_file"

    collision_count=$(jq -n --slurpfile store "$store_file" --slurpfile backup "$backup_file" --argjson ids "$ids_json" '
        ($backup[0].snapshots | map(select(.id as $id | ($ids | index($id)) != null))) as $incoming
        | [$store[0].snapshots[] | . as $old | select($incoming | any(.id == $old.id or .name == $old.name))] | length
    ') || die "unable to read snapshot database"

    if ((collision_count > 0)); then
        confirm "Replace ${collision_count} existing snapshot(s) with imported ones?" || return 0
    fi

    acquire_lock
    new_temp_file
    store_file=$NEW_TEMP_FILE
    read_store_to_file "$store_file"

    new_temp_file
    updated_file=$NEW_TEMP_FILE
    jq --argjson ids "$ids_json" --slurpfile backup "$backup_file" '
        ($backup[0].snapshots | map(select(.id as $id | ($ids | index($id)) != null))) as $incoming
        | .snapshots |= (
            map(select(. as $old | (($incoming | any(.id == $old.id)) or ($incoming | any(.name == $old.name))) | not)) + $incoming
          )
    ' "$store_file" > "$updated_file" || die "unable to update snapshot database"
    validate_snapshot_document "$updated_file" || die "refusing to import invalid snapshot data"
    write_store < "$updated_file"

    snapshot_count=$(jq -r '.snapshots | length' "$updated_file") || die "unable to read snapshot database"
    if ((collision_count > 0)); then
        notify "Imported ${incoming_count} snapshot(s), replaced ${collision_count} (${snapshot_count} saved)"
    else
        notify "Imported ${incoming_count} snapshot(s) (${snapshot_count} saved)"
    fi
}

stop_session() {
    local requested_name=${1:-}
    local session_name current_session prompt current_pane

    require_command tmux

    if [[ -z "$requested_name" ]]; then
        session_name=$(pick_running_session "Stop tmux session: ") || return 0
    else
        session_name=$requested_name
        [[ ! "$session_name" =~ [[:cntrl:]] ]] || die "session name cannot contain control characters"
        if ! tmux_cmd has-session -t "=${session_name}" >/dev/null 2>&1; then
            notify "No running tmux session '${session_name}'"
            return 0
        fi
    fi

    prompt="Stop running tmux session '${session_name}'?"
    if inside_tmux; then
        current_pane=${TMUX_SESSION_MANAGER_SOURCE_PANE:-${TMUX_PANE:-}}
        if [[ -n "$current_pane" ]]; then
            current_session=$(tmux_value "$current_pane" '#{session_name}') || current_session=
            if [[ -n "$current_session" && "$session_name" == "$current_session" ]]; then
                prompt="Stop current tmux session '${session_name}'? Your session will end."
            fi
        fi
    fi

    confirm "$prompt" || return 0

    tmux_cmd kill-session -t "=${session_name}" || die "unable to stop tmux session '${session_name}'"
    notify "Stopped tmux session '${session_name}'"
}

print_table_border() {
    local start=$1
    local separator=$2
    local end=$3
    local first=1
    local segment
    local width

    shift 3
    printf '%s' "${TABLE_BORDER_COLOR}${start}"
    for width in "$@"; do
        if ((first == 0)); then
            printf '%s' "$separator"
        fi
        printf -v segment '%*s' "$((width + 2))" ''
        segment=${segment// /─}
        printf '%s' "$segment"
        first=0
    done
    printf '%s%s\n' "$end" "$TABLE_RESET"
}

print_table_row() {
    local count=$1
    shift
    local -a widths=("${@:1:count}")
    local -a colors=("${@:$((count + 1)):count}")
    local -a values=("${@:$((count * 2 + 1)):count}")
    local index

    printf '%s' "${TABLE_BORDER_COLOR}│"
    for index in "${!widths[@]}"; do
        printf ' %s%-*s%s %s│' \
            "${colors[index]}" "${widths[index]}" "${values[index]}" \
            "$TABLE_RESET" "$TABLE_BORDER_COLOR"
    done
    printf '%s%s\n' "$TABLE_BORDER_COLOR" "$TABLE_RESET"
}

list_snapshots() {
    local store_file row index value_length color
    local -a headers=("Name" "Session" "Windows" "Panes" "Saved At" "Status")
    local -a header_colors=("$TABLE_HEADER_COLOR" "$TABLE_HEADER_COLOR" "$TABLE_HEADER_COLOR" "$TABLE_HEADER_COLOR" "$TABLE_HEADER_COLOR" "$TABLE_HEADER_COLOR")
    local -a data_colors=("$TABLE_NAME_COLOR" "$TABLE_SESSION_COLOR" "$TABLE_COUNT_COLOR" "$TABLE_COUNT_COLOR" "$TABLE_DATE_COLOR" "$TABLE_STATUS_RUNNING_COLOR")
    local -a row_colors=()
    local -a rows=()
    local -a values=()
    local -a widths=()

    require_command jq
    new_temp_file
    store_file=$NEW_TEMP_FILE
    read_store_to_file "$store_file"

    if ! jq -e '.snapshots | length > 0' "$store_file" >/dev/null; then
        printf '%s\n' "No saved tmux sessions"
        return 0
    fi

    mapfile -t rows < <(
        jq -r '.snapshots | sort_by(.saved_at) | reverse[] | [.name, .session.name, (.session.windows | length), ([.session.windows[].panes | length] | add // 0), (.saved_at | if type == "string" then (sub("T"; " ") | .[0:16]) else . end)] | @tsv' "$store_file"
    )

    load_running_sessions
    for index in "${!rows[@]}"; do
        IFS=$'\t' read -r -a values <<< "${rows[$index]}"
        if session_running "${values[1]}"; then
            rows[$index]+=$'\t'"running"
        else
            rows[$index]+=$'\t'"stopped"
        fi
    done

    for index in "${!headers[@]}"; do
        widths[index]=${#headers[index]}
    done
    for row in "${rows[@]}"; do
        IFS=$'\t' read -r -a values <<< "$row"
        for index in "${!headers[@]}"; do
            value_length=${#values[index]}
            if ((value_length > widths[index])); then
                widths[index]=$value_length
            fi
        done
    done

    print_table_border '╭' '┬' '╮' "${widths[@]}"
    print_table_row "${#headers[@]}" "${widths[@]}" "${header_colors[@]}" "${headers[@]}"
    print_table_border '├' '┼' '┤' "${widths[@]}"
    for row in "${rows[@]}"; do
        IFS=$'\t' read -r -a values <<< "$row"
        row_colors=("${data_colors[@]}")
        if [[ "${values[5]}" == "running" ]]; then
            color=$TABLE_STATUS_RUNNING_COLOR
        else
            color=$TABLE_STATUS_STOPPED_COLOR
        fi
        row_colors[5]=$color
        print_table_row "${#headers[@]}" "${widths[@]}" "${row_colors[@]}" "${values[@]}"
    done
    print_table_border '╰' '┴' '╯' "${widths[@]}"
}

parse_arguments() {
    PARSED_ARGUMENTS=()
    while (($#)); do
        case "$1" in
            --yes)
                ASSUME_YES=1
                ;;
            --all)
                ALL_SNAPSHOTS=1
                ;;
            *)
                PARSED_ARGUMENTS+=("$1")
                ;;
        esac
        shift || true
    done
}

main() {
    local command=${1:-}

    if [[ -z "$command" ]]; then
        command=$(pick_command) || return 0
    fi

    case "$command" in
        new)
            shift || true
            new_session
            ;;
        save)
            shift || true
            parse_arguments "$@"
            save_snapshot "${PARSED_ARGUMENTS[0]:-}"
            ;;
        restore)
            shift || true
            restore_snapshot "${1:-}"
            ;;
        delete)
            shift || true
            parse_arguments "$@"
            delete_snapshot "${PARSED_ARGUMENTS[0]:-}"
            ;;
        stop)
            shift || true
            parse_arguments "$@"
            stop_session "${PARSED_ARGUMENTS[0]:-}"
            ;;
        list)
            shift || true
            list_snapshots
            ;;
        export)
            shift || true
            parse_arguments "$@"
            export_snapshots "${PARSED_ARGUMENTS[0]:-}"
            ;;
        import)
            shift || true
            parse_arguments "$@"
            import_snapshots "${PARSED_ARGUMENTS[0]:-}"
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            usage >&2
            return 2
            ;;
    esac
}

main "$@"
