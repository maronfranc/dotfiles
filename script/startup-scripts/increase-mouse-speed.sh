#!/usr/bin/env bash
sleep 2 # Give time for X11 to start and devices to be recognized
# Set mouse speed to maximum allowed. # xinput set-prop $mouse_id "libinput Accel Speed" 1.0

mouse_id=$(xinput list | grep "USB OPTICAL MOUSE" | sed -n 's/.*id=\([0-9]*\).*/\1/p')

# Check if ID was found
if [[ -n "$mouse_id" ]]; then
    xinput set-prop "$mouse_id" "Coordinate Transformation Matrix" 2.95 0 0 0 2.95 0 0 0 1
    # spd-say "Mouse speed increased."
else
    # spd-say "Startup error: USB OPTICAL MOUSE not found"
    exit 1
fi
