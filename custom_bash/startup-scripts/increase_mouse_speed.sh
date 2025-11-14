#!/usr/bin/env bash
# NOTE: Run `xinput` to find the mouse id. 
# My current mouse is "USB OPTICAL MOUSE" id=11.
sleep 2  # Give time for X to start and devices to be recognized
# Set mouse speed to maximum allowed. # xinput set-prop 11 "libinput Accel Speed" 1.0
# Set mouse speed 5 times above current speed.

mouse_id=$(xinput list | grep "USB OPTICAL MOUSE" | sed -n 's/.*id=\([0-9]*\).*/\1/p')

# Check if ID was found
if [[ -n "$mouse_id" ]]; then
    xinput set-prop "$mouse_id" "Coordinate Transformation Matrix" 5.75 0 0  0 5.75 0  0 0 1
    spd-say "Mouse speed increased."
else
    spd-say "Startup error: USB OPTICAL MOUSE not found"
    exit 1
fi
