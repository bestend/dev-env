#!/usr/bin/env bash
set -euo pipefail

TARGET_USER=${TARGET_USER:?TARGET_USER is required}
TARGET_HOME=${TARGET_HOME:?TARGET_HOME is required}
TARGET_GROUP=${TARGET_GROUP:-$(id -gn "${TARGET_USER}")}
OH_MY_ZSH_DIR="${TARGET_HOME}/.oh-my-zsh"
CUSTOM_DIR="${OH_MY_ZSH_DIR}/custom"
PLUGIN_DIR="${CUSTOM_DIR}/plugins"

reset_git_dir() {
  local repo_url="$1"
  local dest="$2"
  if [[ -d "${dest}" && ! -d "${dest}/.git" ]]; then
    rm -rf "${dest}"
  fi
  if [[ ! -d "${dest}/.git" ]]; then
    mkdir -p "$(dirname "${dest}")"
    git clone --depth=1 "${repo_url}" "${dest}"
  fi
}

reset_git_dir https://github.com/ohmyzsh/ohmyzsh.git "${OH_MY_ZSH_DIR}"
reset_git_dir https://github.com/zsh-users/zsh-autosuggestions.git "${PLUGIN_DIR}/zsh-autosuggestions"
reset_git_dir https://github.com/zsh-users/zsh-syntax-highlighting.git "${PLUGIN_DIR}/zsh-syntax-highlighting"
reset_git_dir https://github.com/Aloxaf/fzf-tab.git "${PLUGIN_DIR}/fzf-tab"

mkdir -p "${TARGET_HOME}/.cache" "${TARGET_HOME}/.config" "${TARGET_HOME}/.local/bin" "${TARGET_HOME}/.dev-env-overrides"
chown -R "${TARGET_USER}:${TARGET_GROUP}" "${TARGET_HOME}"
