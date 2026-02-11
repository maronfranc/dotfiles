#!/usr/bin/env bash

INTERNAL="eDP-1"
EXTERNAL="HDMI-1-0"

# Turn on HDMI and mirror the internal display
xrandr \
    --output "$EXTERNAL" --auto --same-as "$INTERNAL" \
    --output "$INTERNAL" --auto
