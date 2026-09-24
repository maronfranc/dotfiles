#!/usr/bin/env bash
# Script to download video with yt-dlp and docker image.
# SEE: https://hub.docker.com/search?q=yt-dlp
echo -ne "\033]0; yt-dlp download video\007" # Script title.

# ===== ===== Style ===== ===== #
C_BOLD=$'\033[1m'
C_RED=$'\033[31m'
C_GREEN=$'\033[32m'
C_CYAN=$'\033[36m'
C_NC=$'\033[0m' # Reset color | No color.

# ===== ===== Container Runtime Detection ===== ===== #
# Determine which container runtime to use (podman or docker).
# Podman is preferred if installed, otherwise falls back to docker.
if command -v podman >/dev/null 2>&1; then
    CONTAINER_APP="podman"
    CONTAINER_URL="docker.io/jauderho/yt-dlp:latest"
elif command -v docker >/dev/null 2>&1; then
    CONTAINER_APP="docker"
    CONTAINER_URL="jauderho/yt-dlp:latest"
else
    echo -e "${C_RED}Error: Neither 'podman' nor 'docker' is installed.${C_NC}"
    echo "Please install one of them to continue."
    exit 1
fi
download_dir="$HOME/Downloads/yt-dlp"

# ===== ===== Input ===== ===== #
read -p "• Enter the YouTube video URL: " video_url

if [[ -z "$video_url" ]]; then
    echo "Error: No URL provided"
    exit 1
fi

# Prompt for additional options (time clip, quality, etc.).
read -p "• Additional options (${C_BOLD}${C_CYAN}time | clip | quality${C_NC})? \
${C_BOLD}${C_CYAN}[y/yes/s/sim]${C_NC}: " opts_confirm
if [[ "${opts_confirm,,}" =~ ^(y|yes|s|sim)$ ]]; then
    # Time clip selection.
    read -p "• Enter start time ${C_BOLD}${C_CYAN}(e.g. 01:30)${C_NC} or press Enter to skip: " start_time
    read -p "• Enter end time   ${C_BOLD}${C_CYAN}(e.g. 15:45)${C_NC} or press Enter to skip: " end_time

    # Quality selection via --list-formats.
    read -p "• Choose quality   ${C_BOLD}${C_CYAN}[list | pick | none]${C_NC}: " quality_action
    if [[ "${quality_action,,}" == "list" ]]; then
        echo ""
        echo "${C_BOLD}Available formats:${C_NC}"
        $CONTAINER_APP run --rm -v "$download_dir":/Downloads \
            $CONTAINER_URL \
            --list-formats "$video_url" 2>/dev/null
        echo ""
        read -p "  Select format code ${C_BOLD}${C_CYAN}(ID or IDs {video_id}+{audio_id}, e.g. 229+324)${C_NC}: " \
            format_code
        [[ -n "$format_code" ]] && format_args=(-f "$format_code")
    elif [[ "${quality_action,,}" == "pick" ]]; then
        echo ""

        # Build list of human-readable formats.
        declare -a fmt_ids=()
        declare -a fmt_labels=()
        while IFS= read -r line; do
            # Parse: ID  EXT  RESOLUTION  ...
            id=$(echo "$line" | awk '{print $1}')
            ext=$(echo "$line" | awk '{print $2}')
            res=$(echo "$line" | awk '{print $3}')
            fps=$(echo "$line" | awk '{print $4}')
            vcodec=$(echo "$line" | grep -oP 'codecs="\K[^"]+')

            # Skip rows that don't look like format headers (skip empty, separator, summary lines).
            [[ -z "$id" || "$id" =~ ^[A-Z]+$ ]] && continue
            [[ "$id" =~ ^[[:space:]]*$ ]] && continue

            label="${id} (${ext}, ${res:-audio})"
            fmt_ids+=("$id")
            fmt_labels+=("$label")
        done < <($CONTAINER_APP run --rm -v "$download_dir":/Downloads \
            $CONTAINER_URL \
            --list-formats "$video_url" 2>/dev/null)

        if [[ ${#fmt_ids[@]} -eq 0 ]]; then
            echo "${C_RED}No formats found.${C_NC}"
        else
            echo "${C_BOLD}Available formats (select by number):${C_NC}"
            for i in "${!fmt_ids[@]}"; do
                printf "  %3d) %s\n" "$((i+1))" "${fmt_labels[$i]}"
            done
            echo ""
            read -p "  Select format number: " sel_num
            if [[ "$sel_num" =~ ^[0-9]+$ && "$sel_num" -ge 1 && "$sel_num" -le ${#fmt_ids[@]} ]]; then
                format_args=(-f "${fmt_ids[$((sel_num-1))]}")
                echo -e "  ${C_GREEN}Selected: ${fmt_labels[$((sel_num-1))]}${C_NC}"
            else
                echo -e "  ${C_RED}Invalid selection. Using default quality.${C_NC}"
            fi
        fi
    fi
fi

validate_time() {
    local time_input="$1"

    # Validate `HH:MM:SS` or `MM:SS` format.
    if ! [[ "$time_input" =~ ^([0-9]{1,2}:)?[0-9]{1,2}(:[0-9]{2})?$ ]]; then
        echo "❌ ${C_RED}Invalid time format: $time_input${C_NC}"
        echo "Please use HH:MM:SS or MM:SS format."
        return 1
    fi

    # Additional check for valid time values.
    local hours minutes seconds
    if [[ "$time_input" =~ ^([0-9]{1,2}):([0-9]{1,2}):([0-9]{2})$ ]]; then
        hours="${BASH_REMATCH[1]}"
        minutes="${BASH_REMATCH[2]}"
        seconds="${BASH_REMATCH[3]}"
        [[ $minutes -lt 60 && $seconds -lt 60 ]] || return 1
    elif [[ "$time_input" =~ ^([0-9]{1,2}):([0-9]{1,2})$ ]]; then
        hours=""
        minutes="${BASH_REMATCH[1]}"
        seconds="${BASH_REMATCH[2]}"
        [[ $seconds -lt 60 ]] || return 1
    fi

    return 0
}

if [[ -n "$start_time" ]]; then
    if ! validate_time "$start_time"; then
        echo "❌ ${C_RED}Error: Invalid start time format.${C_NC}"
        exit 1
    fi
fi

if [[ -n "$end_time" ]]; then
    if ! validate_time "$end_time"; then
        echo "❌ ${C_RED}Error: Invalid end time format.${C_NC}"
        exit 1
    fi
fi

# ===== ===== Format command ===== ===== #
format_args=()
time_clip_args=()
if [[ -n "$start_time" && -n "$end_time" ]]; then
    # Both times provided - download specific range
    time_clip_args+=("--download-sections" "*$start_time-$end_time")
elif [[ -n "$start_time" ]]; then
    # Only start time provided - download from start time
    time_clip_args+=("--download-sections" "*$start_time-")
elif [[ -n "$end_time" ]]; then
    # Only end time provided - download to end time
    time_clip_args+=("--download-sections" "*-$end_time")
fi

# Clean url to be saved in the file name.
formatted_video_url=${video_url#http://}
formatted_video_url=${formatted_video_url#https://}
formatted_video_url=${formatted_video_url#www.}
# Replace "/" with "__".
formatted_video_url=${formatted_video_url//\//__}
# # Replace "?" with "__".
formatted_video_url=$(echo "$formatted_video_url" | sed 's/[<>:"/\\|?*]/__/g')
# Remove Youtube playlist query strings.
formatted_video_url=$(echo "$formatted_video_url" |
    sed 's/&list=[^&]*//g' | sed 's/&index=[^&]*//g')

# ===== ===== Execute command ===== ===== #
mkdir -p "$download_dir"

# Saved file name: `[$channel]*$10:01-$12:01 youtube.com__watch__v=$video_id- $title.mp4`.
# SEE: [trim-filenames](#https://github.com/yt-dlp/yt-dlp/issues/3494#issuecomment-2532759099).
# `--restrict-filenames` - Restrict filenames to only ASCII characters, avoid "&" and spaces in filenames.
# `-f` format - Select specific format (default: auto, 480p).
# Use the detected container runtime variable ($CONTAINER_APP)
$CONTAINER_APP run --rm -v "$download_dir":/Downloads \
    $CONTAINER_URL \
    --restrict-filenames \
    "${format_args[@]}" \
    "${time_clip_args[@]}" \
    -o "/Downloads/[%(uploader)s]${formatted_video_url} - %(title).100B.%(ext)s" \
    "$video_url"

if [ $? -eq 0 ]; then
    echo -e "✅ ${C_GREEN}Download completed successfully.${C_NC}"
else
    echo -e "🟥 ${C_RED}Download failed.${C_NC}"
    exit 1
fi
