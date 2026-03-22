#!/usr/bin/env bash

rofi_cmd="rofi -dmenu -i -p Power"

options="\
 Laptop_only\n\
󰍹  HDMI_only\n\
󰍺  Side_by_side\n\
󱞟  Mirror_all_connected\
"

chosen=$(echo -e "$options" | $rofi_cmd)

case "$chosen" in
  *HDMI_only*)
    ~/.local/bin/hardware-display-hdmi-only
  ;;
  *Laptop_only*)
    ~/.local/bin/hardware-display-laptop-only
  ;;
  *Side_by_side*)
    ~/.local/bin/hardware-display-side-by-side
  ;;
  *Mirror_all_connected*)
    ~/.local/bin/hardware-display-mirror-all-connected
  ;;
esac
