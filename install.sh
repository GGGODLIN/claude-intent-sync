#!/bin/bash
set -e

# claude-intent-sync installer
# Installs the /sync skill, cross-machine directory, README, and .gitignore into ~/.claude/

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing claude-intent-sync into: $CLAUDE_DIR"

# Ensure ~/.claude/ structure exists
mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/cross-machine/pending" "$CLAUDE_DIR/cross-machine/done"

# Install /sync skill
cp "$SCRIPT_DIR/skills/sync.md" "$CLAUDE_DIR/commands/sync-claude-setting-cross-platform.md"
echo "  ✓ Installed /sync skill"

# Install cross-machine README (executor guide for the receiving Claude)
cp "$SCRIPT_DIR/templates/cross-machine-README.md.template" "$CLAUDE_DIR/cross-machine/README.md"
echo "  ✓ Installed cross-machine/README.md"

# .gitkeep so empty pending/ and done/ persist in git
touch "$CLAUDE_DIR/cross-machine/pending/.gitkeep"
touch "$CLAUDE_DIR/cross-machine/done/.gitkeep"
echo "  ✓ Created cross-machine/ structure"

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
echo "  1. Add the Cross-Machine Sync section from templates/CLAUDE.md.snippet to your ~/.claude/CLAUDE.md"
echo "  2. Create a private GitHub repo for your config (e.g., your-username/claude-config)"
echo "  3. Initialize git in ~/.claude/ and push:"
echo "       cd ~/.claude"
echo "       git init"
echo "       git branch -M main"
echo "       git remote add origin git@github.com:your-username/claude-config.git"
echo "       git add -A"
echo "       git commit -m 'chore: initial config'"
echo "       git push -u origin main"
echo "  4. On your other machine(s): git clone that repo to ~/.claude/"
echo "  5. Use /sync to push changes and /sync pull to fetch + execute cross-machine tasks"
echo ""
echo "See https://github.com/GGGODLIN/claude-intent-sync for docs and examples."
