#!/usr/bin/env bash
# Strict mode: fail fast and loudly.
set -e          # Stop on first error.
set -u          # Disallow unset variables.
set -o pipefail # Propagate pipeline failures.

VERSION="$(curl -fsSL https://go.dev/VERSION?m=text | head -n1)"
ARCH="linux-amd64"

DOWNLOAD_URL="https://go.dev/dl/${VERSION}.${ARCH}.tar.gz"

echo "Latest stable Go version: ${VERSION}"
echo "Download URL:"
echo "  ${DOWNLOAD_URL}"
echo

read -r -p "Install ${VERSION}? [y/N]: " CONFIRM

case "${CONFIRM}" in
  y|Y|yes|YES)
    echo "Proceeding with installation..."
    ;;
  *)
    echo "Installation cancelled."
    exit 0
    ;;
esac

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

ARCHIVE="${TMP_DIR}/go.tar.gz"

echo "Downloading Go..."
curl -fsSL "${DOWNLOAD_URL}" -o "${ARCHIVE}"

echo "Installing to /usr/local/go..."
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "${ARCHIVE}"

if ! grep -q '/usr/local/go/bin' ~/.bashrc; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
fi

export PATH="$PATH:/usr/local/go/bin"

echo ""
go version
echo "Go ${VERSION} installed successfully."
