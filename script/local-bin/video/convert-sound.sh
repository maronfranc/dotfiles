#!/usr/bin/env bash
# Strict mode: fail fast and loudly.
set -e          # Stop on first error.
set -o pipefail # Propagate pipeline failures.

echo -ne "\033]0; ffmpeg convert sound\007" # Script title.

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

# Define operation options with full messages
REMOVE_SOUND_OPTION="🔇 Remove video sound."
EXTRACT_AUDIO_OPTION="🎵 Extract video audio."

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

# ===== ===== Operation selection ===== ===== #
# Get operation type
operation=$(select_options "Select operation:" <<EOF
$REMOVE_SOUND_OPTION
$EXTRACT_AUDIO_OPTION
EOF
)

# ===== ===== Remove video sound ===== ===== #
if [[ "$operation" == "$REMOVE_SOUND_OPTION" ]]; then
    echo "Selected: $input_file"

    # ===== ===== Format ===== ===== #
    input_ext="${input_file##*.}"
    output_file="${input_file%.*}_(no_sound).${input_ext}"

    if [[ -f "$output_file" ]]; then
        echo "Error: Output file '$output_file' already exists." >&2
        exit 1
    fi

    # ===== ===== Execute command ===== ===== #
    echo "Removing sound from video"
    ffmpeg -i "$input_file" -c:v copy -an "$output_file"

    if [ $? -eq 0 ]; then
        echo "✅ ${C_GREEN}Video sound removed successfully.${C_NC}"
        echo "File: $output_file"
    else
        echo "🟥 ${C_RED}Removing video sound failed.${C_NC}"
        exit 1
    fi
fi

# ===== ===== Audio extraction ===== ===== #
if [[ "$operation" == "$EXTRACT_AUDIO_OPTION" ]]; then
    echo "Selected: $input_file"

    # ===== ===== Audio extraction ===== ===== #
    output_file="${input_file%.*}.mp3"

    if [[ -f "$output_file" ]]; then
        echo "Error: Output file '$output_file' already exists." >&2
        exit 1
    fi

    echo "Extracting audio from $input_file"
    ffmpeg -i "$input_file" -vn -ar 44100 -ac 2 -ab 192k -f mp3 "$output_file"

    if [ $? -eq 0 ]; then
        echo "✅ ${C_GREEN}Audio extracted successfully.${C_NC}"
        echo "File: $output_file"
    else
        echo "🟥 ${C_RED}Audio extraction failed.${C_NC}"
        exit 1
    fi
fi
