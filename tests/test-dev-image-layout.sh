#!/usr/bin/env bash
set -euo pipefail

required_files=(
  Dockerfile
  .dockerignore
  docker-compose.yml
  .devcontainer/devcontainer.json
  scripts/install-system-tools.sh
  scripts/install-runtimes.sh
  scripts/install-codex.sh
  scripts/install-claude.sh
  scripts/install-code-server.sh
  scripts/configure-shell.sh
  scripts/configure-fzf.sh
  scripts/configure-tmux.sh
  scripts/configure-theme.sh
  scripts/configure-ssh.sh
  scripts/entrypoint.sh
  scripts/healthcheck.sh
  home/.zshrc
  home/.tmux.conf
  home/.p10k.zsh
  docs/dev-image.md
  .env.example
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || { echo "missing: $file"; exit 1; }
done

grep -q 'FROM ubuntu:24.04' Dockerfile || { echo 'Dockerfile missing ubuntu:24.04'; exit 1; }
grep -q 'powerlevel10k' home/.zshrc || { echo '.zshrc missing powerlevel10k'; exit 1; }
grep -q 'code-server' docker-compose.yml || { echo 'compose missing code-server'; exit 1; }
grep -q '@openai/codex' scripts/install-codex.sh || { echo 'codex install script missing package'; exit 1; }
grep -q '@anthropic-ai/claude-code' scripts/install-claude.sh || { echo 'claude install script missing package'; exit 1; }
grep -q 'openssh-server' scripts/install-system-tools.sh || { echo 'system tools missing openssh-server'; exit 1; }
grep -q 'ENABLE_SSHD' docker-compose.yml || { echo 'compose missing ssh toggle'; exit 1; }
grep -q 'AllowUsers' scripts/configure-ssh.sh || { echo 'ssh config missing AllowUsers'; exit 1; }
grep -q '/usr/sbin/sshd' scripts/entrypoint.sh || { echo 'entrypoint missing sshd launch'; exit 1; }

echo 'layout test passed'
