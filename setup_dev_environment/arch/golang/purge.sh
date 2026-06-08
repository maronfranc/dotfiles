#!/usr/bin/env bash
# Strict mode: fail fast and loudly.
set -e          # Stop on first error.
set -u          # Disallow unset variables.
set -o pipefail # Propagate pipeline failures.

GO_PATH="/usr/local/go"

if [[ ! -d "${GO_PATH}" ]]; then
  echo "Go is not installed at ${GO_PATH}"
  exit 0
fi

echo "Detected Go installation:"
echo "  ${GO_PATH}"
echo

read -r -p "Uninstall Go? [y/N]: " CONFIRM

case "${CONFIRM}" in
  y|Y|yes|YES)
    echo "Removing Go installation..."
    ;;
  *)
    echo "Uninstall cancelled."
    exit 0
    ;;
esac

sudo rm -rf "${GO_PATH}"

echo "Go uninstalled successfully."
echo
echo "Optional manual cleanup:"
echo "  Remove /usr/local/go/bin from your shell profile (~/.bashrc, ~/.zshrc, etc.)"
