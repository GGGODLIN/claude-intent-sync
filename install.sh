#!/bin/bash
set -e

# sync-claude-config non-plugin installer
# Use this path for CI, headless, or when the plugin system is unavailable.
# For normal use, prefer: /install-plugin sync-claude-config

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing sync-claude-config (non-plugin path) into: $CLAUDE_DIR"

# Ensure target dirs exist
mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/cross-machine/pending" "$CLAUDE_DIR/cross-machine/done"

# Copy command files with -prefixed names (non-plugin path has no namespace)
for cmd in push pull setup; do
  cp "$SCRIPT_DIR/commands/$cmd.md" "$CLAUDE_DIR/commands/sync-claude-config-$cmd.md"
  echo "  ✓ Installed /sync-claude-config-$cmd"
done

# .gitkeep so empty pending/ and done/ persist in git
touch "$CLAUDE_DIR/cross-machine/pending/.gitkeep"
touch "$CLAUDE_DIR/cross-machine/done/.gitkeep"

# Install cross-machine README (executor guide for the receiving Claude)
cp "$SCRIPT_DIR/templates/cross-machine-README.md.template" "$CLAUDE_DIR/cross-machine/README.md"
echo "  ✓ Installed cross-machine/README.md"

# Install .gitignore if not exists
if [ ! -f "$CLAUDE_DIR/.gitignore" ]; then
  cp "$SCRIPT_DIR/templates/gitignore.template" "$CLAUDE_DIR/.gitignore"
  echo "  ✓ Installed .gitignore"
else
  echo "  ⚠ .gitignore already exists — skipped (review templates/gitignore.template for additions)"
fi

# Print next steps
echo ""
echo "Installation complete."
echo ""
echo "Next steps:"
echo "  1. Append the snippet from templates/CLAUDE.md.snippet to your ~/.claude/CLAUDE.md"
echo "  2. Run /sync-claude-config-setup in Claude Code to begin the bootstrap"
echo ""
echo "See https://github.com/GGGODLIN/sync-claude-config for docs and examples."
