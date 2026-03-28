#!/usr/bin/env bash
set -euo pipefail

TARGET_HOME=${TARGET_HOME:?TARGET_HOME is required}
mkdir -p "${TARGET_HOME}/.config/fzf"
cat > "${TARGET_HOME}/.config/fzf/defaults.zsh" <<'ZEOF'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height=60% --layout=reverse --border --preview "bat --style=numbers --color=always --line-range=:200 {}"'
ZEOF
