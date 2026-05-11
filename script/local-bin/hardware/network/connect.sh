#!/usr/bin/env bash

C_CYAN=$'\033[36m'
C_NC=$'\033[0m' # Reset color | No color.

select_options() {
    local prompt=$1

    fzf --height=25% \
        --border \
        --pointer="▶" \
        --prompt="$prompt" \
        --bind="j:down,k:up,h:abort,l:accept"
}

echo ""
echo "            ${C_CYAN}Looking for availabe networks...${C_NC}"
NETWORK=$(nmcli device wifi list | select_options "Select network: ")
SSID=$(echo "$NETWORK" | awk '{print $3}')
if [ -z "$SSID" ]; then
    echo "No network selected... doing nothing."
    exit 1
fi

# Hidden password prompt.
read -s -p "Wi-Fi ($SSID) Password: " PASSWORD
echo ""

nmcli radio wifi on # Enable Wi-Fi.
nmcli device wifi connect "$SSID" password "$PASSWORD"

if [ $? -eq 0 ]; then
    echo "Connected to $SSID"
else
    echo "Failed to connect to $SSID"
fi
