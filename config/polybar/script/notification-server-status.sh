#!/bin/bash
NOTIF_SERVER="${HOME}/.local/bin/notification-server"
if "$NOTIF_SERVER" status 2>/dev/null | grep -q "running"; then
    echo "%{F#FFB52A}%{F-}"
else
    echo "%{F#999999}%{F-}"
fi
