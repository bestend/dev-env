#!/usr/bin/env bash
set -euo pipefail

CONTAINER_BIN=${CONTAINER_BIN:-docker}
CONTAINER_RUN_ARGS=${CONTAINER_RUN_ARGS:-}
IMAGE_TAG=${1:-all-in-one-dev:latest}
SSH_NAME=dev-env-ssh-test
CODE_NAME=dev-env-code-test
SSH_PORT=${SSH_PORT:-2222}
CODE_SERVER_PORT=${CODE_SERVER_PORT:-8080}

cleanup() {
  "${CONTAINER_BIN}" rm -f "${SSH_NAME}" "${CODE_NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

cleanup

# shellcheck disable=SC2086
"${CONTAINER_BIN}" run -d ${CONTAINER_RUN_ARGS} --name "${SSH_NAME}" -e ENABLE_SSHD=true -p "${SSH_PORT}:2222" "${IMAGE_TAG}" >/dev/null
sleep 5
python3 - <<PY
import socket
s = socket.socket()
s.settimeout(5)
s.connect(("127.0.0.1", int("${SSH_PORT}")))
print("ssh_port_open")
s.close()
PY

# shellcheck disable=SC2086
"${CONTAINER_BIN}" run -d ${CONTAINER_RUN_ARGS} --name "${CODE_NAME}" -e ENABLE_CODE_SERVER=true -e CODE_SERVER_PASSWORD=changeme -p "${CODE_SERVER_PORT}:8080" "${IMAGE_TAG}" >/dev/null
sleep 8
python3 - <<PY
import socket
s = socket.socket()
s.settimeout(5)
s.connect(("127.0.0.1", int("${CODE_SERVER_PORT}")))
print("code_server_port_open")
s.close()
PY
curl -I --max-time 10 "http://127.0.0.1:${CODE_SERVER_PORT}" | grep -E 'HTTP/|Location:'

echo 'service smoke test passed'
