#!/usr/bin/env bash
# Strict mode: fail fast and loudly.
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

if ! updates_arch=$(checkupdates 2>/dev/null | wc -l); then
    updates_arch=0
fi

if ! updates_aur=$(paru -Qum | wc -l); then
    # if ! updates_aur=$(cower -u 2> /dev/null | wc -l); then
    # if ! updates_aur=$(trizen -Su --aur --quiet | wc -l); then
    updates_aur=0
fi

updates=$(("$updates_arch" + "$updates_aur"))

re='^[0-9]+$'
if ! [[ $updates_arch =~ $re ]]; then
    exit 1
fi

if ! [[ $updates_arch =~ $re ]]; then
    exit 1
fi

last_update=$(last pacman |
    head -2 |
    awk 'NR==2 {print $5"-"$4"-"$7}' 2>/dev/null ||
    echo "unknown")


echo "• Uname -r:   $(uname -r)"
if [ "$last_update" != "unknown" ]; then
    days_from_last_update=$(
        date_diff=$(echo "$(date +%s) - $(date -d "$last_update" +%s)" | bc)
        echo $((date_diff / 86400))
    )
    echo "• Updated_at: $last_update ($days_from_last_update days ago)"
fi
echo "• Pacman:     $updates_arch"
if [ "$updates_aur" -gt 0 ]; then
    echo "• AUR:        $updates_aur"
fi
