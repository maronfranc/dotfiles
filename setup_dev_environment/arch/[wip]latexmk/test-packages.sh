#!/usr/bin/env bash

# List of packages to install
packages=(
    texlive-bin
    texlive-core
    texlive-latex
    texlive-latexrecommended
    texlive-latexextra
    texlive-fontsextra
    texlive-xetex
    texlive-luatex
    latexmk
)

missing=()

for pkg in "${packages[@]}"; do
    # Important Arch nuance:
    # pacman -Si → checks remote repos
    # pacman -Qi → checks installed packages only
    if ! pacman -Si "$pkg" &>/dev/null; then
        missing+=("$pkg")
    fi
done

if ((${#missing[@]} > 0)); then
    echo "The following packages were NOT found:"
    for m in "${missing[@]}"; do
        echo "  - $m"
    done
    exit 1
fi

echo "All packages found. Proceeding with installation..."
# sudo pacman -S --needed --noconfirm "${packages[@]}"
