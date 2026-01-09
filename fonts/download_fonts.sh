#!/usr/bin/env bash
set -e  # Exit on any error
set -u  # Treat unset variables as errors

REPO="ryanoasis/nerd-fonts"
ASSET_PATTERN="Hack.tar.xz"
TMP_DIR="/tmp"
FONT_DIR="$HOME/.fonts"

# Create font directory if it doesn't exist
mkdir -p "$FONT_DIR"
cd "$TMP_DIR"

# Download latest Hack.tar.xz from GitHub releases
# SEE: https://github.com/ryanoasis/nerd-fonts/releases
DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" \
    | jq -r ".assets[] | select(.name | test(\"$ASSET_PATTERN\"; \"i\")) | .browser_download_url")

echo "Downloading $DOWNLOAD_URL ..."
curl -L -o Hack.tar.xz "$DOWNLOAD_URL"

# Extract to ~/.fonts
echo "Extracting to $FONT_DIR ..."
tar -xf Hack.tar.xz -C "$FONT_DIR"

echo "Done! Fonts installed in $FONT_DIR"
