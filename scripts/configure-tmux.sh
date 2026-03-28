#!/usr/bin/env bash
set -euo pipefail

TARGET_USER=${TARGET_USER:?TARGET_USER is required}
TARGET_HOME=${TARGET_HOME:?TARGET_HOME is required}
TARGET_GROUP=${TARGET_GROUP:-$(id -gn "${TARGET_USER}")}
TPM_DIR="${TARGET_HOME}/.tmux/plugins/tpm"

mkdir -p "$(dirname "${TPM_DIR}")"
if [[ ! -d "${TPM_DIR}/.git" ]]; then
  git clone --depth=1 https://github.com/tmux-plugins/tpm "${TPM_DIR}"
fi
chown -R "${TARGET_USER}:${TARGET_GROUP}" "${TARGET_HOME}/.tmux"

su - "${TARGET_USER}" -c "HOME=${TARGET_HOME} tmux start-server >/dev/null 2>&1 || true"
su - "${TARGET_USER}" -c "HOME=${TARGET_HOME} ${TPM_DIR}/bin/install_plugins >/dev/null 2>&1 || true"
