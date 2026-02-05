alias cpu_temp="paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'"

alias testaudioinputhere="arecord -d 3 "./audio-$(date '+%Y-%m-%d_%H-%M-%S').wav""
alias audiotestinputhere="arecord -d 3 "./audio-$(date '+%Y-%m-%d_%H-%M-%S').wav""

# alias xsetled='xset led named "Scroll Lock"' # Keyboard scroll lock
