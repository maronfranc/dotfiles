#!/usr/bin/env bash

INTERNAL="eDP-1"
EXTERNAL="HDMI-1-0"

# Turn on HDMI and internal display off
xrandr \
    --output "$INTERNAL" --off \
    --output "$EXTERNAL" --auto --primary
