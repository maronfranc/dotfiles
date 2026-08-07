#!/usr/bin/env bash

if ! command -v scrot &> /dev/null; then
    notify-send -t 5000 -u critical \
        "Dependency error" \
        'Please install "scrot" CLI to take screenshots.'
    exit 1
fi

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"
iso_date=$(date +%Y-%m-%dT%H:%M:%SZ)
FILENAME="${SCREENSHOT_DIR}/${iso_date}.png"

save_full() {
    scrot --file "$FILENAME" \
        --exec 'notify-send "Full screenshot saved" "$f"'
}

save_window() {
    scrot --file "$FILENAME" --focussed \
        --exec 'notify-send "Window screenshot saved" "$f"'
}

save_selection() {
    notify-send "Screenshot save" "Click a window to screenshot it." -t 750
    scrot --file "$FILENAME" --select \
        --exec 'notify-send "Window screenshot saved" "$f"'
}

case "${1:-full}" in
    full)      save_full ;;
    window)    save_window ;;
    selection) save_selection ;;
    *)
        echo "Usage: $0 [full|window|selection]"
        exit 1
    ;;
esac
