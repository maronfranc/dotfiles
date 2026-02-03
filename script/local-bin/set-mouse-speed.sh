#!/usr/bin/env bash
# Set mouse speed to maximum allowed. 
# 1. Example: `set_mouse_speed 3.00` to increase speed.
# 2. Example: `set_mouse_speed 1.00` to reset.
new_speed=$1
mouse_name="USB OPTICAL MOUSE"
mouse_id=$(xinput list | grep "$mouse_name" | sed -n 's/.*id=\([0-9]*\).*/\1/p')

# Check if ID was found.
if [[ -n "$mouse_id" ]]; then
    xinput set-prop "$mouse_id" \
        "Coordinate Transformation Matrix" \
        $new_speed 0 0 0 $new_speed 0 0 0 1
else
    echo "Mouse not found: $mouse_name"
    exit 1
fi
