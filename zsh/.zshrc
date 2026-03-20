# =============================================================================
# ZSH Configuration — managed via ~/.dotfiles
# =============================================================================

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git z docker kubectl)
[[ -d "$ZSH" ]] && source "$ZSH/oh-my-zsh.sh"

# History
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# PATH
export PATH="$HOME/.local/bin:$GOPATH/bin:$PATH"

# Go
export GOPATH="$HOME/go"

# direnv
eval "$(direnv hook zsh)"

# Aliases — tmux
alias dev='~/.dotfiles/tmux/dev-session.sh'
alias ta='tmux attach -t'
alias tls='tmux ls'
alias tnew='tmux new-session -s'

# Machine-local overrides and secrets — never committed
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
