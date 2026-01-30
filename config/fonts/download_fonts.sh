#!/usr/bin/env bash
# Strict mode: fail fast and loudly
set -e          # stop on first error
set -u          # disallow unset variables
set -o pipefail # propagate pipeline failures

# This script Download fonts and move to `~/.fonts/`.
# Prompt asking to update cache run: `fc-cache -fv`.
# To find the correct font NAME run: `fc-list | grep -i hack`.
# SEE list:https://www.nerdfonts.com/font-downloads
# SEE fonts:
#   1. https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.0/Hack.zip
#   2. https://github.com/source-foundry/Hack/tree/v3.003
REPO="ryanoasis/nerd-fonts"
ASSET_PATTERN="Hack.tar.xz"
TMP_DIR="/tmp"
FONT_DIR="$HOME/.fonts"
# FONT_DIR="$HOME/.local/share/fonts"

# Create font directory if it doesn't exist
mkdir -p "$FONT_DIR"
cd "$TMP_DIR"

# Download latest Hack.tar.xz from GitHub releases
# SEE: https://github.com/ryanoasis/nerd-fonts/releases
DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" |
    jq -r ".assets[] | select(.name | test(\"$ASSET_PATTERN\"; \"i\")) | .browser_download_url")

echo "Downloading $DOWNLOAD_URL ..."
curl -L -o Hack.tar.xz "$DOWNLOAD_URL"

# Extract to ~/.fonts
echo "Extracting to $FONT_DIR ..."
tar -xf Hack.tar.xz -C "$FONT_DIR"

echo "Done! Fonts installed in $FONT_DIR"
