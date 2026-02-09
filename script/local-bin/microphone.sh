#!/usr/bin/env bash

SOURCE=$(pactl get-default-source)
NOTIFY_ID=9991
STEP=5          # volume step %
XOB_PIPE="/tmp/xobpipe"

get_mute() {
    pactl get-source-mute "$SOURCE" | awk '{print $2}'
}

get_volume() {
    pactl get-source-volume "$SOURCE" \
        | head -n1 \
        | awk -F'/' '{print $2}' \
        | tr -d ' %'
}

send_xob() {
    [[ -p "$XOB_PIPE" ]] && echo "$1" > "$XOB_PIPE"
}

case "$1" in
    toggle)
        pactl set-source-mute "$SOURCE" toggle
        MUTED=$(get_mute)

        if [[ "$MUTED" == "yes" ]]; then
            dunstify -u low -r $NOTIFY_ID "Microphone" "Muted" -i microphone-sensitivity-muted
        else
            VOL=$(get_volume)
            dunstify -u low -r $NOTIFY_ID "Microphone" "Unmuted (${VOL}%)" -i microphone-sensitivity-high
            # send_xob "$VOL"
        fi
        exit 0
    ;;
    up)
        pactl set-source-mute "$SOURCE" 0
        pactl set-source-volume "$SOURCE" +${STEP}%
        VOL=$(get_volume)
        send_xob "$VOL"
    ;;
    down)
        pactl set-source-volume "$SOURCE" -${STEP}%
        VOL=$(get_volume)
        send_xob "$VOL"
    ;;
esac

# Polybar output
MUTED=$(get_mute)
VOL=$(get_volume)

if [[ "$MUTED" == "yes" ]]; then
    echo "%{F#ff5555}%{F-}"
else
    echo "%{F#50fa7b} ${VOL}%%{F-}"
fi
