#!/usr/bin/env bash
# Strict mode: fail fast and loudly.
set -e          # Stop on first error.
set -o pipefail # Propagate pipeline failures.

echo -ne "\033]0; ffmpeg clipping video\007" # Script title.

# ===== ===== Style ===== ===== #
C_BOLD=$'\033[1m'
C_RED=$'\033[31m'
C_GREEN=$'\033[32m'
C_CYAN=$'\033[36m'
C_NC=$'\033[0m' # Reset color | No color.

# ===== ===== Input ===== ===== #
select_options() {
    local prompt=$1

    fzf --height=20% \
        --border \
        --pointer="▶" \
        --prompt="$prompt" \
        --bind="j:down,k:up,h:abort,l:accept"
}

# Get video files with their sizes for selection.
input_file=$(find . -maxdepth 1 -type f \( \
    -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" -o \
    -name "*.mov" -o -name "*.wmv" -o -name "*.flv" -o \
    -name "*.webm" \
    \) 2>/dev/null | while read -r file; do
    size_mb=$(stat -c %s "$file" 2>/dev/null | awk '{print int($1/1024/1024)}' 2>/dev/null)
    echo "[${size_mb:-0} MB] $(basename "$file")"
done | select_options "Select input file:" | sed 's/^\[[0-9]* MB\] //')

if [[ -z "$input_file" ]]; then
    echo "Error: No input file provided." >&2
    exit 1
fi

echo "Selected: $input_file"
read -p "• Enter start time ${C_BOLD}${C_CYAN}(e.g. 01:30)${C_NC} or press Enter to skip: " start_time
read -p "• Enter end time   ${C_BOLD}${C_CYAN}(e.g. 15:45)${C_NC} or press Enter to skip: " end_time
if [[ -z "$start_time" && -z "$end_time" ]]; then
    echo "No time values provided... doing nothing."
    exit 1
fi

# ===== ===== Format ===== ===== #
# Format time values for filename (replace : with _).
f_start_time="${start_time//:/_}"
f_end_time="${end_time//:/_}"
input_ext="${input_file##*.}"
# Build output filename with time stamps.
output_file=""
if [[ -n "$start_time" && -n "$end_time" ]]; then
    output_file="${input_file%.*}_${f_start_time}_to_${f_end_time}.${input_ext}"
elif [[ -n "$start_time" ]]; then
    output_file="${input_file%.*}_${f_start_time}_to_end.${input_ext}"
elif [[ -n "$end_time" ]]; then
    output_file="${input_file%.*}_from_start_to_${f_end_time}.${input_ext}"
fi

# Get the duration of the file for total time calculation.
duration=$(ffprobe -v error -show_entries format=duration -of default=nw=1 "$input_file" 2>/dev/null)
formatted_total="" 
if [ -n "$duration" ]; then
    # Format the total time as `hh_mm_ss`.
    total_hours=$(awk "BEGIN {printf \"%02d\", int($duration/3600)}")
    total_minutes=$(awk "BEGIN {printf \"%02d\", int(($duration%3600)/60)}")
    total_seconds=$(awk "BEGIN {printf \"%02d\", int($duration%60)}")
    if [[ "$total_hours" == "00" ]]; then
        formatted_total="${total_minutes}_${total_seconds}"
    else
        formatted_total="${total_hours}_${total_minutes}_${total_seconds}"
    fi
fi

# Add total time to the filename.
if [[ -n "$start_time" && -n "$end_time" ]]; then
    output_file="${output_file%.*}__original=${formatted_total}.${input_ext}"
elif [[ -n "$start_time" ]]; then
    output_file="${output_file%.*}__original=${formatted_total}.${input_ext}"
elif [[ -n "$end_time" ]]; then
    output_file="${output_file%.*}__original=${formatted_total}.${input_ext}"
fi

if [[ -f "$output_file" ]]; then
    echo "Error: Output file '$output_file' already exists." >&2
    exit 1
fi

# ===== ===== Execute command ===== ===== #
if [[ -n "$start_time" && -n "$end_time" ]]; then
    echo "Clipping video from $start_time to $end_time"
    ffmpeg -i "$input_file" -ss "$start_time" -to "$end_time" -preset fast -crf 23 -y "${output_file}"
elif [[ -n "$start_time" ]]; then
    echo "Clipping video from $start_time to end"
    ffmpeg -i "$input_file" -ss "$start_time" -preset fast -crf 23 -y "${output_file}"
elif [[ -n "$end_time" ]]; then
    echo "Clipping video from beginning to $end_time"
    ffmpeg -i "$input_file" -to "$end_time" -preset fast -crf 23 -y "${output_file}"
fi

if [ $? -eq 0 ]; then
    echo "✅ ${C_GREEN}Video clipped successfully.${C_NC}"
    echo "File: $output_file"
else
    echo "🟥 ${C_RED}Video clip failed.${C_NC}"
    exit 1
fi
