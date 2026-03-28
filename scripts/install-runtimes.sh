#!/usr/bin/env bash
set -euo pipefail

NODE_MAJOR=${NODE_MAJOR:-22}
PNPM_VERSION=${PNPM_VERSION:-10.33.0}
UV_VERSION=${UV_VERSION:-0.10.3}
LAZYGIT_VERSION=${LAZYGIT_VERSION:-0.56.0}

curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash -
apt-get update
apt-get install -y --no-install-recommends \
  gh \
  nodejs \
  pipx \
  python3 \
  python3-pip \
  python3-venv

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
curl -fsSL -o "$TMP_DIR/lazygit.tar.gz" "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -C "$TMP_DIR" -xf "$TMP_DIR/lazygit.tar.gz" lazygit
install "$TMP_DIR/lazygit" /usr/local/bin/lazygit

npm install -g "npm@latest"
corepack enable
corepack prepare "pnpm@${PNPM_VERSION}" --activate
corepack prepare yarn@stable --activate
export PIPX_HOME=/opt/pipx
export PIPX_BIN_DIR=/usr/local/bin
pipx install "uv==${UV_VERSION}"
chmod -R a+rX /opt/pipx
