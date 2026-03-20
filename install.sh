#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"

symlink() {
  local src="$DOTFILES/$1"
  local dest="$HOME/$2"

  # Backup existing real file (not symlink)
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/"
    echo "  backed up: $dest → $BACKUP_DIR/"
  fi

  ln -sf "$src" "$dest"
  echo "  linked:    $dest → $src"
}

echo "==> Installing dotfiles from $DOTFILES"

symlink zsh/.zshrc         .zshrc
symlink zsh/.zshenv        .zshenv
symlink tmux/.tmux.conf    .tmux.conf
symlink git/.gitconfig     .gitconfig

echo ""
echo "==> Creating ~/.zshrc.local if it doesn't exist"
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  cat > "$HOME/.zshrc.local" <<'EOF'
# Machine-local overrides and secrets — this file is NEVER committed to git
# Add your API keys, private paths, and machine-specific settings here.

# Example:
# export ANTHROPIC_API_KEY="sk-ant-..."
# export NATS_URL="nats://localhost:4222"
# export TEMPORAL_HOST="localhost:7233"
EOF
  echo "  created:   ~/.zshrc.local (edit this with your secrets)"
else
  echo "  exists:    ~/.zshrc.local (not overwritten)"
fi

echo ""
echo "Done. Reload shell with: source ~/.zshrc"
echo "  Edit secrets in:         ~/.zshrc.local"
