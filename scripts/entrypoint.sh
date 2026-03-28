#!/usr/bin/env bash
set -euo pipefail

TARGET_USER=${TARGET_USER:-dev}
TARGET_HOME=${TARGET_HOME:-/home/${TARGET_USER}}
TARGET_GROUP=${TARGET_GROUP:-$(id -gn "${TARGET_USER}" 2>/dev/null || echo "${TARGET_USER}")}
ENABLE_SSHD=${ENABLE_SSHD:-false}
ENABLE_CODE_SERVER=${ENABLE_CODE_SERVER:-false}
ENABLE_TMUX_PLUGIN_BOOTSTRAP=${ENABLE_TMUX_PLUGIN_BOOTSTRAP:-true}
CODE_SERVER_PORT=${CODE_SERVER_PORT:-8080}
SSH_PORT=${SSH_PORT:-2222}
CODE_SERVER_AUTH=${CODE_SERVER_AUTH:-password}

mkdir -p /workspace/.dev-env-overrides "${TARGET_HOME}/.dev-env-overrides" "${TARGET_HOME}/.ssh"
chmod 700 "${TARGET_HOME}/.ssh" || true
chown "${TARGET_USER}:${TARGET_GROUP}" /workspace /workspace/.dev-env-overrides "${TARGET_HOME}" "${TARGET_HOME}/.dev-env-overrides" "${TARGET_HOME}/.ssh" 2>/dev/null || true

if [[ -n "${AUTHORIZED_KEYS_SOURCE:-}" && -f "${AUTHORIZED_KEYS_SOURCE}" ]]; then
  cp "${AUTHORIZED_KEYS_SOURCE}" "${TARGET_HOME}/.ssh/authorized_keys"
  chown "${TARGET_USER}:${TARGET_GROUP}" "${TARGET_HOME}/.ssh/authorized_keys"
  chmod 600 "${TARGET_HOME}/.ssh/authorized_keys"
fi

if [[ "${ENABLE_TMUX_PLUGIN_BOOTSTRAP}" == "true" ]] && [[ -x "${TARGET_HOME}/.tmux/plugins/tpm/bin/install_plugins" ]]; then
  su - "${TARGET_USER}" -c "HOME=${TARGET_HOME} ${TARGET_HOME}/.tmux/plugins/tpm/bin/install_plugins >/dev/null 2>&1 || true"
fi

if [[ "${ENABLE_SSHD}" == "true" ]]; then
  sed -i "s/^Port .*/Port ${SSH_PORT}/" /etc/ssh/sshd_config.d/99-dev-image.conf || true
  ssh-keygen -A
  /usr/sbin/sshd
fi

if [[ "${ENABLE_CODE_SERVER}" == "true" ]]; then
  if [[ "${CODE_SERVER_AUTH}" == "password" ]]; then
    export PASSWORD=${CODE_SERVER_PASSWORD:-changeme}
  fi
  su - "${TARGET_USER}" -c "HOME=${TARGET_HOME} code-server --bind-addr 0.0.0.0:${CODE_SERVER_PORT} --auth ${CODE_SERVER_AUTH} /workspace" &
fi

if [[ "$(id -u)" -eq 0 ]]; then
  exec runuser -u "${TARGET_USER}" -- "$@"
fi

exec "$@"
