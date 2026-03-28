#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG=${1:-all-in-one-dev:latest}

docker run --rm "$IMAGE_TAG" zsh -lc 'git --version && zsh --version && tmux -V && node --version && pnpm --version && python3 --version && uv --version && codex --version && claude --version && code-server --version'
docker run --rm "$IMAGE_TAG" zsh -lc 'test -f ~/.p10k.zsh && test -f ~/.tmux.conf && grep -q powerlevel10k ~/.zshrc'
docker history --no-trunc "$IMAGE_TAG" >/dev/null

echo 'runtime smoke test passed'
