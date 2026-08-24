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

# ===== ===== Input ===== ===== #
read -p "• Enter the YouTube video URL: " video_url

if [[ -z "$video_url" ]]; then
    echo "Error: No URL provided"
    exit 1
fi

# Prompt for additional options (time clip, quality, etc.).
read -p "• Additional options (${C_BOLD}${C_CYAN}time | clip${C_NC})? \
${C_BOLD}${C_CYAN}[y/yes/s/sim]${C_NC}: " opts_confirm
if [[ "${opts_confirm,,}" =~ ^(y|yes|s|sim)$ ]]; then
    read -p "• Enter start time ${C_BOLD}${C_CYAN}(e.g. 01:30)${C_NC} or press Enter to skip: " start_time
    read -p "• Enter end time   ${C_BOLD}${C_CYAN}(e.g. 15:45)${C_NC} or press Enter to skip: " end_time
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
download_dir="$HOME/Downloads/yt-dlp"
mkdir -p "$download_dir"

# Saved file name: `[$channel]*$10:01-$12:01 youtube.com__watch__v=$video_id- $title.mp4`.
# SEE: [trim-filenames](#https://github.com/yt-dlp/yt-dlp/issues/3494#issuecomment-2532759099).
# `--restrict-filenames` - Restrict filenames to only ASCII characters, avoid "&" and spaces in filenames.
# `--embed-subs` - Download and embed video subtitles(CC).
# `-f "bestvideo[height<=480][ext=mp4]+bestaudio[ext=m4a]/best[height<=480][ext=mp4]"` - Select 480p max quality.

# Use the detected container runtime variable ($CONTAINER_APP)
$CONTAINER_APP run --rm -v "$download_dir":/Downloads \
    $CONTAINER_URL \
    --restrict-filenames \
    "${time_clip_args[@]}" \
    -o "/Downloads/[%(uploader)s]${formatted_video_url} - %(title).100B.%(ext)s" \
    "$video_url"

if [ $? -eq 0 ]; then
    echo -e "✅ ${C_GREEN}Download completed successfully.${C_NC}"
else
    echo -e "🟥 ${C_RED}Download failed.${C_NC}"
    exit 1
fi
