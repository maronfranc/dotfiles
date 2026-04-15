#!/usr/bin/env bash
# Overwrite `imv` command to cycle through dir images.

# Enable nullglob so that unmatched globs expand to nothing
#   (without this, *.jpg would stay as the literal string "*.jpg"
#   if no files match, which would break the image list).
shopt -s nullglob nocaseglob

open_img_and_dir() {
    target="$1"
    target_base="$(basename -- "$target")"
    target_dir="$(dirname "$target")/"

    # Check if target contains a slash indicating a path(works with `./`).
    if [[ "$target" == */* ]]; then
        original_dir="$PWD"
        cd "$target_dir"
        # Build images array with current directory paths.
        valid_images=(*.jpg *.jpeg *.png *.webp *.gif *.bmp *.tiff *.tif *.avif *.svg)
        cd "$original_dir"
    fi

    found=false
    ordered_imgs=()

    for img in "${valid_images[@]}"; do
        img_file="$(basename -- "$img")"
        if [[ "$img_file" == "$target_base" ]]; then
            found=true
            selected_image=("${target_dir}${img}")
        else
            ordered_imgs+=("${target_dir}${img}")
        fi
    done

    if ! $found; then
        echo "\`img\` file not found in image list: $1"
        exit 1
    fi

    # Order $selected_image first then all other images in directory.
    ordered_imgs=($selected_image "${ordered_imgs[@]}")
    exec imv "${ordered_imgs[@]}"
}

open_dir_imgs() {
    valid_images=(*.jpg *.jpeg *.png *.webp *.gif *.bmp *.tiff *.tif *.avif *.svg)
    if [ ${#valid_images[@]} -eq 0 ]; then
        echo "\`img\`: no images found in current directory."
        exit 1
    fi
    exec imv "${valid_images[@]}"
}

open_url_img() {
    curl "$1" | imv -
}

# Empty param means should open current dir.
# TODO: detect if exists and is a dir.
if [ -z "$1" ]; then
    open_dir_imgs
    exit 0
fi

if [[ "$1" == https://* ]] || [[ "$1" == http://* ]]; then
    open_url_img "$1"
    exit 0
fi

open_img_and_dir "$1"
