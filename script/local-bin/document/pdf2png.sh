#!/usr/bin/env bash
# This script:
# 1. Find .pdf files.
# 2. Reate `./(generated)` dir.
# 3. Insert one .png for each page in the .pdf file.
# 
# Strict mode: fail fast and loudly.
set -e          # Stop on first error
set -u          # Disallow unset variables
set -o pipefail # Propagate pipeline failures

# Check dependencies
if ! command -v pdftoppm >/dev/null 2>&1; then
  echo "Error: pdftoppm is not installed."
  exit 1
fi

if ! command -v fzf >/dev/null 2>&1; then
  echo "Error: fzf is not installed."
  exit 1
fi

# Select PDF file
PDF_FILE=$(find . -type f -iname "*.pdf" 2>/dev/null | \
  fzf --height=40% \
      --reverse \
      --border \
      --prompt="Select posting path > " \
      --bind="j:down,k:up,h:abort,l:accept")

# Exit if nothing selected
if [[ -z "${PDF_FILE:-}" ]]; then
  echo "No file selected."
  exit 0
fi

# Get directory and base name
PDF_DIR="$(dirname "$PDF_FILE")"
BASE_NAME="$(basename "$PDF_FILE" .pdf)"

# OUTPUT_DIR="$PDF_DIR/(generated)" # Create inside the PDF directory.
OUTPUT_DIR="$PWD/(generated)" # Create in the current dir.
mkdir -p "$OUTPUT_DIR"

echo "Converting:       $PDF_FILE"
echo "Output directory: $OUTPUT_DIR"

# Convert to PNG (300 DPI, one file per page)
pdftoppm -r 300 -png "$PDF_FILE" "$OUTPUT_DIR/$BASE_NAME"

echo "Done."
