#!/bin/bash
# Script prints: [M:%memory:2%%,C:%cpu:2%%,G:%gpu:2%%]

cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.0f", usage}')
mem=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
on_click_command="alacritty -t htop -e htop"

echo "\
%{A1:i3-msg 'exec --no-startup-id $on_click_command':}\
 %{F#54cefa}M:${mem}%%{F-}\
 %{F#7fffd4}C:${cpu}%%{F-}\
 %{F#88AAD4}G:${gpu}%%{F-}\
%{A}"
