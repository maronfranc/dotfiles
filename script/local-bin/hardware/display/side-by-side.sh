#!/usr/bin/env bash

INTERNAL="eDP-1"
EXTERNAL="HDMI-1-0"

# Turn on HDMI and keep the internal display to the left
xrandr \
    --output $EXTERNAL --auto --primary \
    --output $INTERNAL --auto --left-of $EXTERNAL
