Sync Claude Code config across computers using a Git repo at `~/.claude/`.

## Push mode (default)

1. Run `cd ~/.claude && git status` to see what changed
2. Run `git add -A && git diff --cached --stat` to preview staged changes
3. **Pre-commit task check** (heuristic, no extra LLM call): Look at the file paths in the staged diff. If any of these patterns appear, ask the user whether the change warrants a cross-machine task before committing:
   - `hooks/*.sh` or `hooks/*.ps1` or any new shell script
   - `settings.local.json` (would actually be gitignored, but warn if accidentally tracked)
   - Any file mentioning `crontab`, `launchctl`, `schtasks`, `systemd`, `brew`, `apt`, `winget` in its content (skip if the change is in a markdown doc)
   - Any new file in `cross-machine/pending/` — confirm the user wrote it intentionally, not accidentally
   If nothing matches, proceed silently.
4. If there are changes, commit with a Conventional Commits message (feat/fix/chore/docs/refactor) and push
5. If no changes, report "已是最新，無需同步" / "Already up to date, nothing to sync"
6. Report the sync result with the commit hash and push status

## Pull mode

Triggered when the user says "pull" or "拉":

1. Run `cd ~/.claude && git pull --rebase origin main`
2. After pull, scan for cross-machine tasks:
   - List files in `~/.claude/cross-machine/pending/` (ignore `.gitkeep`)
   - For each `.md` file, check if a same-named file exists in `~/.claude/cross-machine/done/`
   - If exists in `done/` → skip (already completed on this or another machine)
   - If not in `done/` → present as a new task with name and one-line goal extracted from the task file
3. If the user wants to execute a task:
   - Read the full task file (and `~/.claude/cross-machine/README.md` for execution guidance)
   - Adapt to the local OS, package manager, and conventions
   - Execute, verifying end state matches the Goal
   - Copy the task file to `~/.claude/cross-machine/done/<name>.md` with appended completion frontmatter (`completed_by`, `completed_at`) and an Execution summary section
4. If no new tasks, report "無新任務" / "No new tasks"

## Notes

- The Git repo at `~/.claude/` is the single source of truth for cross-machine sync
- `.gitignore` excludes session data, plugins, cache, and machine-specific files
- Never commit `settings.local.json` or files under `projects/`, `sessions/`, `plugins/`
- For details on writing and executing tasks, read `~/.claude/cross-machine/README.md`
