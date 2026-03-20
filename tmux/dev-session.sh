#!/usr/bin/env bash
# Usage: dev-session.sh [session-name]
# If session exists, attach. If not, create with standard window layout.
# tmux runs on THIS machine — SSH in from other terminals and run: tmux attach -t bluefunda

SESSION="${1:-bluefunda}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Session '$SESSION' exists. Attaching..."
  tmux attach -t "$SESSION"
  exit 0
fi

echo "Creating session '$SESSION'..."

# Create session with first window
tmux new-session -d -s "$SESSION" -n "editor" -x 220 -y 50

# Window 2: claude — for Claude Code tasks
tmux new-window -t "$SESSION" -n "claude"

# Window 3: services — NATS, Temporal, Docker
tmux new-window -t "$SESSION" -n "services"

# Window 4: git/misc
tmux new-window -t "$SESSION" -n "git"

# Send startup commands
tmux send-keys -t "$SESSION:services" "echo 'Start services here: docker-compose up, NATS, Temporal'" Enter
tmux send-keys -t "$SESSION:claude"   "echo 'Run: claude'" Enter

# Focus editor window
tmux select-window -t "$SESSION:editor"

echo ""
echo "Session '$SESSION' created."
echo "  Windows: editor | claude | services | git"
echo "  From another terminal: ssh $(hostname) -t 'tmux attach -t $SESSION'"
echo ""

tmux attach -t "$SESSION"
