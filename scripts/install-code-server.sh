#!/usr/bin/env bash
set -euo pipefail

TARGET_USER=${TARGET_USER:?TARGET_USER is required}
TARGET_HOME=${TARGET_HOME:?TARGET_HOME is required}
TARGET_GROUP=${TARGET_GROUP:-$(id -gn "${TARGET_USER}")}
CODE_SERVER_VERSION=${CODE_SERVER_VERSION:-4.112.0}
ARCH=${ARCH:-amd64}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

curl -fsSL -o "$TMP_DIR/code-server.tar.gz" \
  "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-${ARCH}.tar.gz"
tar -C "$TMP_DIR" -xzf "$TMP_DIR/code-server.tar.gz"
rm -rf /usr/lib/code-server
mv "$TMP_DIR/code-server-${CODE_SERVER_VERSION}-linux-${ARCH}" /usr/lib/code-server
ln -sf /usr/lib/code-server/bin/code-server /usr/local/bin/code-server

mkdir -p "${TARGET_HOME}/.local/share/code-server" "${TARGET_HOME}/.local/share/code-server/extensions"
chown -R "${TARGET_USER}:${TARGET_GROUP}" "${TARGET_HOME}/.local"

extensions=(
  ms-python.python
  ms-python.vscode-pylance
  dbaeumer.vscode-eslint
  esbenp.prettier-vscode
  ms-azuretools.vscode-docker
  eamodio.gitlens
  EditorConfig.EditorConfig
)

for ext in "${extensions[@]}"; do
  su - "${TARGET_USER}" -c "HOME=${TARGET_HOME} code-server --install-extension ${ext}" || \
    echo "warning: failed to preinstall code-server extension ${ext}" >&2
done
