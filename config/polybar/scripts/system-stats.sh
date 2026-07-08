#!/bin/bash
# Script prints: [M:%memory:2%%,C:%cpu:2%%,G:%gpu:2%%]

get_cpu_usage() {
    # Alternative function CPU to the following command:
    ## cpu=$(
    ##     vmstat 1 2 |            # Take two vmstat samples, 1 second apart.
    ##     tail -1 |               # Use only the second (current) sample.
    ##     awk '{ print 100-$15 }' # CPU usage = 100 - idle percentage (field 15).
    ## )
    read cpu user nice system idle iowait irq softirq steal guest guest_nice </proc/stat
    total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle1=$idle

    sleep 1

    read cpu user nice system idle iowait irq softirq steal guest guest_nice </proc/stat
    total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle2=$idle

    awk -v t1="$total1" -v t2="$total2" -v i1="$idle1" -v i2="$idle2" '
        BEGIN { printf "%.0f", 100 * (1 - (i2 - i1) / (t2 - t1)) }
    '
}

color_temperature() {
    local n="$1"

    # Package `bc` is required to check temperature value.
    if ! command -v bc >/dev/null 2>&1; then
        echo ""
        return 0
    fi

    if (($(echo "$n < 25" | bc -l))); then
        echo "#1D9BF0"
    elif (($(echo "$n <= 50" | bc -l))); then
        echo "#EAD27A" # echo "#FACC15"
    elif (($(echo "$n <= 75" | bc -l))); then
        echo "#FFB703" # echo "#F4A261"
    else
        echo "#DC2626"
    fi
}

cpu=$(get_cpu_usage)
mem=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)

mem_color=$(color_temperature "$mem")
cpu_color=$(color_temperature "$cpu")
gpu_color=$(color_temperature "$gpu")

on_click_command="ghostty -e btop"

echo "\
%{A1:i3-msg 'exec --no-startup-id $on_click_command':}\
%{F$mem_color}M:${mem}%%{F-} \
%{F$cpu_color}C:${cpu}%%{F-} \
%{F$gpu_color}G:${gpu}%%{F-}\
%{A}"
