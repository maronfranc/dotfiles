#!/usr/bin/env bash

set -e

echo "Removing LaTeX environment..."

sudo pacman -Rns --noconfirm \
    texlive-bin \
    texlive-core \
    texlive-latexrecommended \
    texlive-latexextra \
    texlive-fontsextra \
    texlive-xetex \
    texlive-luatex \
    latexmk

echo "Removing orphaned dependencies..."
orphans=$(pacman -Qtdq || true)

if [[ -n "$orphans" ]]; then
    sudo pacman -Rns --noconfirm $orphans
fi

echo "Cleaning package cache..."
sudo pacman -Sc --noconfirm

echo "LaTeX environment removed."
