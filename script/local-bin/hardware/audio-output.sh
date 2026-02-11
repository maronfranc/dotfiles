#!/usr/bin/env bash

NOTIFY_ID=9991
STEP=5 # volume step %
TIMEOUT_MS=1000

get_mute() {
    pamixer --get-mute
}

get_volume() {
    pamixer --get-volume
}

get_icon() {
    VOL=$(get_volume)
    # MUTED=$(get_mute)
    # if [[ "$MUTED" == "true" ]] || (( VOL == 0 )); then
    #     echo "audio-volume-muted"
    if (( VOL < 50 )); then
        echo "audio-volume-low"
    elif (( VOL < 80 )); then
        echo "audio-volume-medium"
    else
        echo "audio-volume-high"
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
        "Volume: ${VOL}%" \
        -t "$TIMEOUT_MS" \
        -i "$(get_icon)" \
        -h int:value:"$VOL" \
        -h string:hlcolor:"$COLOR"
}

send_muted_notification() {
    dunstify -u low -r $NOTIFY_ID \
        "Volume" "Muted" \
        -t $TIMEOUT_MS \
        -i audio-volume-muted
}

send_unmuted_notification() {
    dunstify -u low -r $NOTIFY_ID \
        "Volume" "Unmuted (${VOL}%)" \
        -t $TIMEOUT_MS \
        -i audio-volume-high
}

case "$1" in
    toggle)
        pamixer -t
        MUTED=$(get_mute)

        if [[ "$MUTED" == "true" ]]; then
            send_muted_notification
        else
            VOL=$(get_volume)
            send_unmuted_notification
        fi
    ;;
    up)
        pamixer -u # ensure unmuted
        pamixer -i $STEP
        send_volume_notification
    ;;
    down)
        pamixer -d $STEP
        send_volume_notification 
    ;;
esac

# ===== ===== Polybar output ===== ===== #
MUTED=$(get_mute)
VOL=$(get_volume)

if [[ "$MUTED" == "true" ]]; then
    echo "%{F#ff5555} muted%{F-}"
else

    if (( VOL == 0 )); then
        ICON=""
    elif (( VOL < 50 )); then
        ICON=""
    else
        ICON=""
    fi

    echo "%{F#50fa7b}${ICON} ${VOL}%%{F-}"
fi
