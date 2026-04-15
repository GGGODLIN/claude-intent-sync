Push local `~/.claude/` changes to the user's private config repo.

## Preflight — onboarding fallback

Check for `~/.claude/cross-machine/.initialized`. If it does not exist, tell the user this plugin is not yet initialized and defer to the `setup` command. Do not proceed with push.

## Steps

1. Run `cd ~/.claude && git status` to see what changed
2. Run `git add -A && git diff --cached --stat` to preview staged changes
3. **Pre-commit task check** (heuristic, no extra LLM call): Inspect the staged diff. If any of these patterns appear, ask the user whether a cross-machine task should be generated before committing:
   - `hooks/*.sh` or `hooks/*.ps1` or any new shell script
   - `settings.local.json` (would normally be gitignored; warn if accidentally tracked)
   - Any file whose content mentions `crontab`, `launchctl`, `schtasks`, `systemd`, `brew`, `apt`, `winget` (skip this check for markdown docs)
   - Any new file in `cross-machine/pending/` — confirm the user wrote it intentionally
   If nothing matches, proceed silently.
4. If there are changes, commit with a Conventional Commits message (feat/fix/chore/docs/refactor) and push
5. If no changes, report "已是最新，無需同步" / "Already up to date, nothing to sync"
6. Report the sync result with the commit hash and push status

## Notes

- The Git repo at `~/.claude/` is the single source of truth for cross-machine sync.
- `.gitignore` excludes session data, plugins, cache, and machine-specific files.
- Never commit `settings.local.json` or files under `projects/`, `sessions/`, `plugins/`.
