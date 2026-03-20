# =============================================================================
# ZSH Configuration — managed via ~/.dotfiles
# =============================================================================

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git z docker kubectl)
[[ -d "$ZSH" ]] && source "$ZSH/oh-my-zsh.sh"

# Prompt — minimal with git branch and time
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{cyan}(%b)%f'
setopt PROMPT_SUBST
PROMPT='%F{green}%~%f${vcs_info_msg_0_} %F{yellow}%*%f
%F{white}$%f '

# History
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# OS detection
case "$(uname -s)" in
  Darwin)
    # Homebrew paths (Apple Silicon + Intel)
    [[ -d /opt/homebrew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    [[ -d /usr/local/Homebrew ]] && eval "$(/usr/local/bin/brew shellenv)"
    ;;
esac

# Go
export GOPATH="$HOME/go"

# PATH
export PATH="$HOME/.local/bin:$GOPATH/bin:$PATH"

# direnv
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# Aliases — tmux
alias dev='~/.dotfiles/tmux/dev-session.sh'
alias ta='tmux attach -t'
alias tls='tmux ls'
alias tnew='tmux new-session -s'

# Machine-local overrides and secrets — never committed
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
