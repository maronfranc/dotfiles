#!/usr/bin/env bash

thermal_data=$(
    paste <(cat /sys/class/thermal/thermal_zone*/type 2>/dev/null) \
        <(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null) |
        awk '{ printf "%s %.1f\n", $1, $2/1000 }'
)

cpu_float=$(echo "$thermal_data" | awk '$1=="x86_pkg_temp" {print $2}')
mb_float=$(echo "$thermal_data" | awk '$1=="acpitz" {print $2}')
gpu_float=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1)

color_temp() {
    local n="$1"
    
    # Package `bc` is required to check temperature value.
    if ! command -v bc >/dev/null 2>&1; then
        echo "${n}"
        return 0
    fi

    if (($(echo "$n < 50" | bc -l))); then
        echo "#8ACFFF"
    elif (($(echo "$n <= 70" | bc -l))); then
        echo "#FFB703"
    else
        echo "#DC2626"
    fi
}

cpu_hex=$(color_temp "$cpu_float")
gpu_hex=$(color_temp "$gpu_float")
mb_hex=$(color_temp "$mb_float")
on_click_command="alacritty -t htop -e htop"

echo "\
%{A1:i3-msg 'exec --no-startup-id $on_click_command':}\
%{F$mb_hex}MB:${mb_float%.*}°C%{F-} \
%{F$cpu_hex}C:${cpu_float%.*}°C%{F-} \
%{F$gpu_hex}G:${gpu_float%.*}°C%{F-}\
%{A}"
