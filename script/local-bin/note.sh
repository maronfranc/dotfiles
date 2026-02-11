#!/usr/bin/env bash

# Open floating window alacritty with a temporary file open.
alacritty -e sh -c "nvim /tmp/$(date +%Y-%m-%d_%H-%M-%S).md" &

i3-msg -t subscribe '["window"]' | jq -r '
  select(.change=="new")
  | select(.container.window_properties.class=="Alacritty")
  | .container.id
' | head -n1 | while read -r id; do
  i3-msg "[con_id=$id] floating enable, move left"
done
