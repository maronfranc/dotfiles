#!/usr/bin/env bash
# Overwrite `imv` command to cycle through dir images.

# Enable nullglob so that unmatched globs expand to nothing
# (without this, *.jpg would stay as the literal string "*.jpg"
# if no files match, which would break the image list)
shopt -s nullglob

# Common image extensions (case-insensitive)
images=(
    *.jpg *.jpeg *.png *.webp *.gif *.bmp *.tiff *.tif *.avif
    *.JPG *.JPEG *.PNG *.WEBP *.GIF *.BMP *.TIFF *.TIF *.AVIF
)

open_img_and_dir() {
    target="$1"

    # Resolve to basename if path is provided
    target_base="$(basename -- "$target")"

    found=false
    reordered=()

    for img in "${images[@]}"; do
        if [[ "$(basename -- "$img")" == "$target_base" ]]; then
            found=true
            reordered+=("$img")
        fi
    done

    if ! $found; then
        echo "\`img\` file not found in image list: $1"
        exit 1
    fi

    for img in "${images[@]}"; do
        [[ "$(basename -- "$img")" != "$target_base" ]] && reordered+=("$img")
    done

    exec imv "${reordered[@]}"
}

open_dir_imgs() {
    # No images found
    if [ ${#images[@]} -eq 0 ]; then
        echo "img: no images found in current directory"
        exit 1
    fi
    exec imv "${images[@]}"
}

open_url_img() {
    curl "$1" | imv -
}

# Empty param means should open current dir.
if [ -z "$1" ]; then
    open_dir_imgs
    exit 0
fi

if [[ "$1" == https://* ]] || [[ "$1" == http://* ]]; then
    open_url_img "$1"
    exit 0
fi

open_img_and_dir "$1"
