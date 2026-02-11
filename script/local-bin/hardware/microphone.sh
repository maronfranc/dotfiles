#!/usr/bin/env bash

SOURCE=$(pactl get-default-source)
NOTIFY_ID=9992
STEP=5 # volume step %
TIMEOUT_MS=1000

get_mute() {
    pactl get-source-mute "$SOURCE" | awk '{print $2}'
}

get_volume() {
    pactl get-source-volume "$SOURCE" \
        | head -n1 \
        | awk -F'/' '{print $2}' \
        | tr -d ' %'
}

get_icon() {
    MUTED=$(pamixer --default-source --get-mute)
    VOL=$(pamixer --default-source --get-volume)

    if [[ "$MUTED" == "true" ]] || (( VOL == 0 )); then
        echo "microphone-sensitivity-muted"
    elif (( VOL < 50 )); then
        echo "microphone-sensitivity-low"
    elif (( VOL < 80 )); then
        echo "microphone-sensitivity-medium"
    else
        echo "microphone-sensitivity-high"
    fi
}

send_volume_notification() {
    VOL=$(get_volume)
    URGENCY="low"
    COLOR="#a3be8c"

    if [ "$VOL" -eq 0 ]; then
        COLOR="#444444" # muted / zero
    elif [ "$VOL" -le 30 ]; then
        COLOR="#88c0d0" # low (blue)
    elif [ "$VOL" -le 70 ]; then
        COLOR="#a3be8c" # medium (green)
    elif [ "$VOL" -le 100 ]; then
        COLOR="#ebcb8b" # high (yellow)
    elif [ "$VOL" -le 130 ]; then
        COLOR="#d08770" # boosted (orange)
        URGENCY="normal"
    else
        COLOR="#bf616a" # extreme boost (red)
        URGENCY="critical"
    fi

    dunstify -u "$URGENCY" -r "$NOTIFY_ID" \
        "Microphone: ${VOL}%" \
        -t "$TIMEOUT_MS" \
        -i "$(get_icon)" \
        -h int:value:"$VOL" \
        -h string:hlcolor:"$COLOR"
}

send_muted_notification() {
    VOL=$(get_volume)
    dunstify -u low -r $NOTIFY_ID \
        -t $TIMEOUT_MS \
        -i microphone-sensitivity-muted \
        "Microphone" "muted (${VOL}%)"
}

send_unmuted_notification() {
    VOL=$(get_volume)
    dunstify -u low -r $NOTIFY_ID \
        -t $TIMEOUT_MS \
        -i microphone-sensitivity-high \
        "Microphone" "Unmuted (${VOL}%)"
}

case "$1" in
    toggle)
        pactl set-source-mute "$SOURCE" toggle
        MUTED=$(get_mute)

        if [[ "$MUTED" == "yes" ]]; then
            send_muted_notification
        else
            send_unmuted_notification
        fi
    ;;
    up)
        pactl set-source-mute "$SOURCE" 0 # ensure unmuted
        pactl set-source-volume "$SOURCE" +${STEP}%
        send_volume_notification
    ;;
    down)
        pactl set-source-volume "$SOURCE" -${STEP}%
        send_volume_notification
    ;;
esac

# ===== ===== Polybar output ===== ===== #
MUTED=$(get_mute)
VOL=$(get_volume)

if [[ "$MUTED" == "yes" ]]; then
    echo "%{F#ff5555}%{F-}"
else
    echo "%{F#50fa7b} ${VOL}%%{F-}"
fi
