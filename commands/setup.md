Bootstrap cross-machine sync. Ask the user which mode, then run the appropriate flow.

## Step 1 — Ask which mode

Ask: **"Is this your FIRST machine setting up cross-machine sync (Primary), or a SECONDARY machine connecting to an existing setup?"**

Then proceed to the matching section.

## Prerequisites (verify before either flow)

- `git` installed (`git --version`)
- Authenticated GitHub access: check `gh auth status` — if not authenticated, prompt user to run `gh auth login`
- Git identity: check `git config --global user.email` and `user.name`; prompt user to set them if missing

## Primary mode

1. Ask the user for a repo name. Do **not** hardcode a default — guessable repo names reveal the owner-to-repo mapping even when the repo is private.
2. Create the private repo:
   - If `gh` is authenticated: `gh repo create <name> --private`
   - Otherwise: walk the user through creating the repo manually on https://github.com/new and ask for the URL
3. Initialize git and push:
   ```bash
   cd ~/.claude
   git init -b main
   git remote add origin <repo URL>
   git add -A
   git commit -m "chore: initial config"
   git push -u origin main
   ```
4. Write the marker: `mkdir -p ~/.claude/cross-machine && touch ~/.claude/cross-machine/.initialized`
5. Tell the user the repo URL (they need it for secondary machines) and that they can now run `/sync-claude-config:push` from here on.

## Secondary mode

> **Note:** Do NOT use `mv ~/.claude`. On Windows (and sometimes macOS) it fails with Permission denied because Claude Code holds session files open. Use the in-place `git init` approach below.

1. Ask the user for their private config repo URL.
2. Optional backup of the portable subset of `~/.claude/`:
   ```bash
   TS=$(date +%Y%m%d-%H%M%S)
   mkdir -p ~/.claude-backup-$TS
   cp -r ~/.claude/CLAUDE.md ~/.claude/settings.json \
         ~/.claude/skills ~/.claude/commands ~/.claude/rules \
         ~/.claude/agents ~/.claude/hooks ~/.claude/scripts \
         ~/.claude-backup-$TS/ 2>/dev/null || true
   ```
3. Initialize the repo in place:
   ```bash
   cd ~/.claude
   git init -b main
   git remote add origin <repo URL>
   git fetch origin
   git checkout -f -b main origin/main
   ```
4. Write the marker: `mkdir -p ~/.claude/cross-machine && touch ~/.claude/cross-machine/.initialized`
5. Tell the user the new skill may hot-load; if `/sync-claude-config:pull` isn't visible, suggest restarting Claude Code.
6. Suggest running `/sync-claude-config:pull` to scan for pending tasks.

## After both flows

Confirm success and print the command list: `/sync-claude-config:push`, `/sync-claude-config:pull`, `/sync-claude-config:setup`.
