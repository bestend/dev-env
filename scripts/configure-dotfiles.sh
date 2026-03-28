#!/usr/bin/env bash
set -euo pipefail

TARGET_USER=${TARGET_USER:?TARGET_USER is required}
TARGET_HOME=${TARGET_HOME:?TARGET_HOME is required}
TARGET_GROUP=${TARGET_GROUP:-$(id -gn "${TARGET_USER}")}

rsync -a /opt/dev-image/home/ "${TARGET_HOME}/"
mkdir -p "${TARGET_HOME}/.config/code-server" "${TARGET_HOME}/.dev-env-overrides"
chown -R "${TARGET_USER}:${TARGET_GROUP}" "${TARGET_HOME}"
