#!/usr/bin/env bash

rofi_cmd="rofi -dmenu -i -p Power"

options="  Power Off\n\
  Reboot\n\
⏾  Suspend\n\
  Lock"

chosen=$(echo -e "$options" | $rofi_cmd)

case "$chosen" in
  *Power*)
    systemctl poweroff
  ;;
  *Reboot*)
    systemctl reboot
  ;;
  *Suspend*)
    systemctl suspend
  ;;
  *Lock*)
    i3lock --blur 5
  ;;
esac
