export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git sudo direnv zoxide fzf zsh-autosuggestions zsh-syntax-highlighting fzf-tab)

export EDITOR=vim
export VISUAL=vim
export BAT_THEME=TwoDark
export MANPAGER='sh -c "col -bx | bat -l man -p"'
export PATH="$HOME/.local/bin:$PATH"

[[ -f "$HOME/.config/fzf/defaults.zsh" ]] && source "$HOME/.config/fzf/defaults.zsh"

if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi

source "$ZSH/oh-my-zsh.sh"

eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -lah --icons=auto --group-directories-first'
alias lt='eza --tree --level=2 --icons=auto'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias lg='lazygit'
alias ta='tmux attach -t main || tmux new -s main'

bindkey '^f' fzf-file-widget

[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
[[ -f /workspace/.dev-env-overrides/.zshrc ]] && source /workspace/.dev-env-overrides/.zshrc
[[ -f "$HOME/.dev-env-overrides/.zshrc" ]] && source "$HOME/.dev-env-overrides/.zshrc"
