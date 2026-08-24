#!/usr/bin/env bash
set -e
set -u
set -o pipefail

CONFIG_DIR="$PWD"

declare -A DIRS=()
declare -A NAMES=()

echo "------------------------------------------------"
echo "Select configs to load by number:"
idx=1
for dir in "$CONFIG_DIR"/*/; do
  [ -d "$dir" ] || continue
  dir="${dir%/}"
  base=$(basename "$dir")
  if [ -f "$dir/load.sh" ]; then
    DIRS[$idx]="$dir"
    NAMES[$idx]="$base"
    printf "  %d. %s\n" "$idx" "$base"
    idx=$((idx + 1))
  else
    printf "  (skip) %s (no load.sh)\n" "$base"
  fi
done
echo "------------------------------------------------"

total=$((idx - 1))
if [ "$total" -eq 0 ]; then
  echo "No configs found with load.sh."
  exit 0
fi

read -r -p "> " input

nums=($(echo "$input" | tr '[:punct:]' ' '))
selected=()
for num in "${nums[@]}"; do
  if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "$total" ]; then
    selected+=("$num")
  fi
done

if [ ${#selected[@]} -eq 0 ]; then
  echo "No valid selections."
  exit 0
fi

echo ""
echo "================================================"
echo "  Load Summary"
echo "================================================"
echo ""
for num in "${selected[@]}"; do
  printf "  [x] %s\n" "${NAMES[$num]}"
done
echo ""
echo "------------------------------------------------"
echo ""

read -r -p "Proceed? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 1
fi

echo ""
for num in "${selected[@]}"; do
  dir="${DIRS[$num]}"
  base=$(basename "$dir")
  echo "Loading: $base"
  echo "------------------------------------------------"
  (cd "$dir" && bash load.sh)
  echo "Loaded: $base"
  echo "------------------------------------------------"
  echo ""
done

echo "All selected configs loaded."
