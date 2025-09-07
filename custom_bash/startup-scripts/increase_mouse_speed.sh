#!/usr/bin/env bash
# NOTE: Run `xinput` to find the mouse id. 
# My current mouse is "USB OPTICAL MOUSE" id=11.
sleep 2  # Give time for X to start and devices to be recognized
spd-say "Increase mouse speed"
# Set mouse speed to maximum allowed. # xinput set-prop 11 "libinput Accel Speed" 1.0
# Set mouse speed 5 times above current speed.
xinput set-prop 11 "Coordinate Transformation Matrix" 5 0 0  0 5 0  0 0 1
