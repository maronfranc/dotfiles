#!/usr/bin/env bash

# Kill any existing redshift instance.
pkill redshift
# Start redshift without auto-adjust.
redshift -P -O 6500

while true; do
    now=$(date +%H)

    # Start gradual warming (manual control).
    case "$now" in
        "20")
            redshift -P -O 4500
        ;;
        "21")
            redshift -P -O 3800
        ;;
        "22")
            redshift -P -O 3000
        ;;
        "23")
            redshift -P -O 2400
        ;;
        "00")
            redshift -P -O 2000
        ;;
        "06")
            # Reset to normal daylight.
            redshift -P -x
            redshift -P -O 6500
        ;;
        # *) echo "else" ;;
    esac

    sleep 60 # Wait one minute.
done
