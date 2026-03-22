#!/usr/bin/env bash
# # Lightdm start in mirror mode
# - Edit `/etc/lightdm/lightdm.conf`.
# - Add line under `[Seat:*]`: ```
# [Seat:*]:
# display-setup-script=/usr/bin/hardware-display-mirror-all-connected.sh
# ````

SRC="$PWD/local-bin/hardware/display/mirror-all-connected.sh"
TARGET="/usr/bin/hardware-display-mirror-all-connected.sh"
sudo ln -sf "$SRC" "$TARGET"
