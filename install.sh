#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"
OS="$(uname -s)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

info()  { echo "==> $*"; }
ok()    { echo "  $*"; }

command_exists() { command -v "$1" &>/dev/null; }

install_pkg() {
  local pkg="$1"
  if command_exists "$pkg"; then
    ok "already installed: $pkg"
    return
  fi
  echo "  installing $pkg..."
  case "$OS" in
    Darwin) brew install "$pkg" ;;
    Linux)  sudo apt-get install -y "$pkg" ;;
    *)      echo "  unsupported OS for auto-install: $OS"; return 1 ;;
  esac
}

symlink() {
  local src="$DOTFILES/$1"
  local dest="$HOME/$2"

  # Backup existing real file (not symlink)
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/"
    ok "backed up: $dest → $BACKUP_DIR/"
  fi

  ln -sf "$src" "$dest"
  ok "linked:    $dest → $src"
}

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------

info "Detecting OS: $OS"

info "Installing prerequisites"
if [[ "$OS" == "Darwin" ]]; then
  if ! command_exists brew; then
    echo "  Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

install_pkg git
install_pkg tmux
install_pkg zsh
install_pkg direnv

# ---------------------------------------------------------------------------
# Oh My Zsh
# ---------------------------------------------------------------------------

info "Setting up Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  ok "already installed: oh-my-zsh"
else
  echo "  installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  ok "installed: oh-my-zsh"
fi

# ---------------------------------------------------------------------------
# Symlinks
# ---------------------------------------------------------------------------

info "Installing dotfiles from $DOTFILES"

symlink zsh/.zshrc         .zshrc
symlink zsh/.zshenv        .zshenv
symlink tmux/.tmux.conf    .tmux.conf
symlink git/.gitconfig     .gitconfig

# ---------------------------------------------------------------------------
# Machine-local secrets file
# ---------------------------------------------------------------------------

echo ""
info "Creating ~/.zshrc.local if it doesn't exist"
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  cat > "$HOME/.zshrc.local" <<'EOF'
# Machine-local overrides and secrets — this file is NEVER committed to git
# Add your API keys, private paths, and machine-specific settings here.

# Example:
# export ANTHROPIC_API_KEY="sk-ant-..."
# export NATS_URL="nats://localhost:4222"
# export TEMPORAL_HOST="localhost:7233"
EOF
  ok "created:   ~/.zshrc.local (edit this with your secrets)"
else
  ok "exists:    ~/.zshrc.local (not overwritten)"
fi

# ---------------------------------------------------------------------------
# Set default shell to zsh
# ---------------------------------------------------------------------------

info "Checking default shell"
ZSH_PATH="$(which zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  echo "  changing default shell to zsh..."
  if [[ "$OS" == "Darwin" ]]; then
    # macOS: add to /etc/shells if missing, then chsh
    grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
    chsh -s "$ZSH_PATH"
  else
    sudo chsh -s "$ZSH_PATH" "$(whoami)"
  fi
  ok "default shell set to $ZSH_PATH (takes effect on next login)"
else
  ok "already using zsh"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo ""
echo "Done. Reload shell with: source ~/.zshrc"
echo "  Edit secrets in:         ~/.zshrc.local"
