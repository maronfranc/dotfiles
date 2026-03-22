#!/usr/bin/env bash

FILE="config"

SRC="$PWD/$FILE"
TARGET="$HOME/.config/i3/$FILE"

rm -rf "$TARGET"
ln -s "$SRC" "$TARGET"
