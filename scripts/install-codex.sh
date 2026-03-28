#!/usr/bin/env bash
set -euo pipefail

CODEX_VERSION=${CODEX_VERSION:-0.117.0}
npm install -g "@openai/codex@${CODEX_VERSION}"
