#!/usr/bin/env bash

INTERNAL="eDP-1"
EXTERNAL="HDMI-1-0"

# Turn off HDMI and internal display on
xrandr \
    --output "$EXTERNAL" --off \
    --output "$INTERNAL" --auto --primary
