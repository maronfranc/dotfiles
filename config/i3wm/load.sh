#!/usr/bin/env bash

SRC="$PWD/config"
TARGET="$HOME/.config/i3/config"

rm -rf "$TARGET"
ln -s "$SRC" "$TARGET"
