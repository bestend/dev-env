#!/usr/bin/env bash
set -euo pipefail

TARGET_USER=${TARGET_USER:?TARGET_USER is required}
TARGET_HOME=${TARGET_HOME:?TARGET_HOME is required}
TARGET_GROUP=${TARGET_GROUP:-$(id -gn "${TARGET_USER}")}
P10K_DIR="${TARGET_HOME}/.oh-my-zsh/custom/themes/powerlevel10k"

if [[ -d "${P10K_DIR}" && ! -d "${P10K_DIR}/.git" ]]; then
  rm -rf "${P10K_DIR}"
fi
mkdir -p "$(dirname "${P10K_DIR}")"
if [[ ! -d "${P10K_DIR}/.git" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${P10K_DIR}"
fi
chown -R "${TARGET_USER}:${TARGET_GROUP}" "${TARGET_HOME}"
