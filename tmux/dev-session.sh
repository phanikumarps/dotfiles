#!/usr/bin/env bash
# dev-session.sh — multi-machine tmux session
#
# Architecture:
#   mac  ──ssh──►  console (this script runs here)
#                    ├── window: onprem-claude  (ssh into onprem, run claude)
#                    ├── window: onprem-shell   (ssh into onprem, general work)
#                    ├── window: console-shell  (local console tasks)
#                    └── window: monitor        (logs, services status)
#
# Usage: dev-session.sh [session-name]
# Run on: console (the tmux host)

SESSION="${1:-bluefunda}"

# ── Machine config (set in ~/.zshrc.local) ────────────────────────────────────
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
ONPREM_USER="${ONPREM_USER:-}"
ONPREM_HOST="${ONPREM_HOST:-}"

if [[ -z "$ONPREM_USER" || -z "$ONPREM_HOST" ]]; then
  echo "✗ ONPREM_USER and ONPREM_HOST must be set."
  echo "  Add them to ~/.zshrc.local on console:"
  echo "    export ONPREM_USER=\"youruser\""
  echo "    export ONPREM_HOST=\"192.168.1.x\""
  exit 1
fi

ONPREM="$ONPREM_USER@$ONPREM_HOST"

# Attach if session already exists
if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Session '$SESSION' exists. Attaching..."
  tmux attach -t "$SESSION"
  exit 0
fi

echo "Creating session '$SESSION'..."

# Window 1: onprem-claude — SSH into onprem, start claude in ~/src
tmux new-session -d -s "$SESSION" -n "onprem-claude" -x 220 -y 50
tmux send-keys -t "$SESSION:onprem-claude" \
  "ssh -t $ONPREM 'cd ~/src && claude-src'" Enter

# Window 2: onprem-shell — SSH into onprem, interactive shell
tmux new-window -t "$SESSION" -n "onprem-shell"
tmux send-keys -t "$SESSION:onprem-shell" \
  "ssh $ONPREM" Enter

# Window 3: console-shell — local console tasks (git, lightweight ops)
tmux new-window -t "$SESSION" -n "console-shell"
tmux send-keys -t "$SESSION:console-shell" \
  "echo 'Console shell — lightweight tasks only (2GB RAM)'" Enter

# Window 4: monitor — watch services on onprem
tmux new-window -t "$SESSION" -n "monitor"
tmux send-keys -t "$SESSION:monitor" \
  "ssh $ONPREM 'htop'" Enter

# Focus the claude window
tmux select-window -t "$SESSION:onprem-claude"

echo ""
echo "Session '$SESSION' created."
echo "  Windows: onprem-claude | onprem-shell | console-shell | monitor"
echo ""

tmux attach -t "$SESSION"
