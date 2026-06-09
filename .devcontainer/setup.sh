#!/usr/bin/env bash
set -euo pipefail

HUGO_VERSION="${HUGO_VERSION:-0.132.1}"
HUGO_TARBALL="hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_TARBALL}"

echo "Installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl git golang-go

echo "Installing Hugo Extended ${HUGO_VERSION}..."
curl -L --fail -o /tmp/hugo.tar.gz "${HUGO_URL}"
tar -xzf /tmp/hugo.tar.gz -C /tmp hugo
sudo mv /tmp/hugo /usr/local/bin/hugo
hash -r
hugo version

echo "Devcontainer setup complete."
