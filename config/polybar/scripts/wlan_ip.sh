#!/usr/bin/env bash

IFACE="wlan0"

IP=$(ip -4 addr show "$IFACE" | awk '/inet /{print $2}' | cut -d/ -f1)

# Exit silently if no IP (disconnected)
[ -z "$IP" ] && exit 0

# Copy to clipboard
printf "%s" "$IP" | xclip -selection clipboard

# Notify
notify-send "Local IP:" "Copied to clipboard: $IP"
