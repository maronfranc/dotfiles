#!/bin/bash
# Script prints: [M:%memory:2%%,C:%cpu:2%%,G:%gpu:2%%]

cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.0f", usage}')
mem=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
on_click_command="alacritty -t htop -e htop"

color_temperature() {
    local n="$1"
    
    # Package `bc` is required to check temperature value.
    if ! command -v bc >/dev/null 2>&1; then
        echo "${n}"
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

mem_color=$(color_temperature mem)
cpu_color=$(color_temperature cpu)
gpu_color=$(color_temperature gpu)

echo "\
%{A1:i3-msg 'exec --no-startup-id $on_click_command':}\
 %{F$mem_color}M:${mem}%%{F-}\
 %{F$cpu_color}C:${cpu}%%{F-}\
 %{F$gpu_color}G:${gpu}%%{F-}\
%{A}"
