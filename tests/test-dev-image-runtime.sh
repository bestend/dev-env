#!/usr/bin/env bash
set -euo pipefail

CONTAINER_BIN=${CONTAINER_BIN:-docker}
CONTAINER_RUN_ARGS=${CONTAINER_RUN_ARGS:-}
IMAGE_TAG=${1:-all-in-one-dev:latest}

# shellcheck disable=SC2086
"${CONTAINER_BIN}" run --rm ${CONTAINER_RUN_ARGS} "${IMAGE_TAG}" zsh -lc 'git --version && zsh --version && tmux -V && node --version && pnpm --version && python3 --version && uv --version && gh --version && codex --version && claude --version && code-server --version && lazygit --version'
# shellcheck disable=SC2086
"${CONTAINER_BIN}" run --rm ${CONTAINER_RUN_ARGS} "${IMAGE_TAG}" zsh -lc 'test -f ~/.p10k.zsh && test -f ~/.tmux.conf && grep -q powerlevel10k ~/.zshrc && grep -q tmux-resurrect ~/.tmux.conf'
"${CONTAINER_BIN}" history --no-trunc "${IMAGE_TAG}" >/dev/null

echo 'runtime smoke test passed'
