#!/usr/bin/env bash
set -euo pipefail

CLAUDE_CODE_VERSION=${CLAUDE_CODE_VERSION:-2.1.86}
npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}"
