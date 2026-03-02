# alias xsetled='xset led named "Scroll Lock"' # Keyboard scroll lock
alias cpu_temp="paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'"

alias testaudioinputhere="arecord -d 3 "./audio-$(date '+%Y-%m-%d_%H-%M-%S').wav""

testcamera0here() {
    # Alternative command: mpv av://v4l2:/dev/video0
    duration=3

    for arg in "$@"; do
        if [[ "$arg" == "-t" ]]; then
            duration=""
            break
        fi
    done

    ffmpeg -f v4l2 -i /dev/video0 ${duration:+-t $duration} "$@" \
    "recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"
}
