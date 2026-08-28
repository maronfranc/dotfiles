#!/bin/bash
NOTIF_SERVER="${HOME}/.local/bin/notification-server"
if "$NOTIF_SERVER" status 2>/dev/null | grep -q "running"; then
    "$NOTIF_SERVER" stop 2>/dev/null
else
    "$NOTIF_SERVER" start 2>/dev/null
fi
