#!/usr/bin/env bash

rofi_cmd="rofi -dmenu -i -p Power"

options="\
 Laptop_only\n\
󰍹  HDMI_only\n\
󰍺  Side_by_side\n\
󱞟  Mirror\
"

chosen=$(echo -e "$options" | $rofi_cmd)

case "$chosen" in
  *HDMI_only*)
    ~/.local/bin/display-hdmi-only
  ;;
  *Laptop_only*)
    ~/.local/bin/display-laptop-only
  ;;
  *Side_by_side*)
    ~/.local/bin/display-side-by-side
  ;;
  *Mirror*)
    ~/.local/bin/display-mirror
  ;;
esac
