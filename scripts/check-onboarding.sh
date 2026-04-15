#!/bin/bash
# SessionStart hook for sync-claude-config plugin.
# Emits additionalContext only when plugin is installed but not initialized.

MARKER="$HOME/.claude/cross-machine/.initialized"

# Silent if already initialized
if [ -f "$MARKER" ]; then
  exit 0
fi

# Emit context asking Claude to offer setup
cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "The sync-claude-config plugin is installed but has not been initialized on this machine (no ~/.claude/cross-machine/.initialized marker file exists). If the user shows any interest in cross-machine sync, or at a natural pause, proactively offer to run /sync-claude-config:setup to walk through the one-time setup. Do this at most once per session."
  }
}
EOF
