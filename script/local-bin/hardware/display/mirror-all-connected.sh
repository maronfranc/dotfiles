#!/usr/bin/env bash

# Set primary display
PRIMARY="DP-1"

# Set mirror resolution
RESOLUTION="1920x1080"

# Detect connected displays
for OUTPUT in $(xrandr --query | grep " connected" | awk '{print $1}'); do
    if [ "$OUTPUT" != "$PRIMARY" ]; then
        xrandr --output $OUTPUT --mode $RESOLUTION --same-as $PRIMARY
    else
        xrandr --output $OUTPUT --mode $RESOLUTION --primary
    fi
done
