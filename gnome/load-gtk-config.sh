#!/usr/bin/env bash

gtk_dir3="$HOME/.config/gtk-3.0"
gtk_dir4="$HOME/.config/gtk-4.0"

load_file() {
  local dir=$1
  local file="$dir/gtk.css"

  mkdir -p $dir
  rm -rf $file

  echo "Running: ln -s $(pwd)/gtk.css $file"
  ln -s $(pwd)/gtk.css $file
}

load_file $gtk_dir3
load_file $gtk_dir4
