#!/usr/bin/env bash
# Detects if camera is actively being used by applications.
# Use param `kill` to stop all camera recording.

is_camera_in_use() {
    # Check for active camera locks in /dev.
    if ls /dev/video* 2>/dev/null | head -n 1 | grep -q video; then
        # Check if any process is using the camera.
        for device in /dev/video*; do
            if [ -e "$device" ]; then
                # Check if any process is using this device.
                if lsof "$device" 2>/dev/null | grep -q .; then
                    return 0  # Camera in use.
                fi
            fi
        done
    fi
    return 1  # Camera not in use.
}

kill_camera_processes() {
    # Get processes using camera devices.
    local devices=$(ls /dev/video* 2>/dev/null)
    for device in $devices; do
        if [ -e "$device" ]; then
            # Kill all processes using this device
            lsof "$device" 2>/dev/null | awk 'NR>1 {print $2}' | xargs -r kill -9 2>/dev/null
        fi
    done
    
    # Also try killing common camera applications.
    pkill -f "chrome.*camera\|firefox.*camera\|brave.*camera\|meet\|google.*meet"
    
    # Small delay to allow processes to terminate.
    sleep 0.2
}

if [ "$1" = "kill" ]; then
    kill_camera_processes
    pkill -RTMIN+10 polybar
    exit 0
fi

if is_camera_in_use; then
    echo " recording..."
    exit 0
else
    # Camera not in use, empty string to hide button.
    echo ""
    exit 0
fi
