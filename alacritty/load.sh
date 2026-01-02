#!/usr/bin/env bash

alacritty_dir=~/.config/alacritty
alacritty_file="$alacritty_dir"/alacritty.toml

mkdir -p $alacritty_dir
rm -rf $alacritty_file

ln -s $(pwd)/alacritty.toml $alacritty_file

read -rp "Do you want to reload cached fonts? [y/n]: " answer
echo $answer
# answer="${answer,,}" # to lower case

case "$answer" in
    [Yy]|[Yy][Ee][Ss])
        fc-cache -fv
    ;;
    # [Nn]|[Nn][Oo])
    *)
        echo "Fonts cache reload skipped."
    ;;
esac

echo "RUNNED: \n 1. ln -s $(pwd)/alacritty.toml $alacritty_file"
echo "- 1. Link file: ln -s $(pwd)/alacritty.toml $alacritty_file"
echo "- 2. Update cache: fc-cache -fv"
echo "- 3. Search if hack fonts are loaded: fc-list | grep -i hack"
echo -e "4. Check if these icons( \uf115  \uf07c  \uf0c7 ) will work."
