Sync Claude Code config across computers using a Git repo at `~/.claude/`.

Steps (push mode, default):
1. Run `cd ~/.claude && git status` to see what changed
2. Run `git add -A && git diff --cached --stat` to preview staged changes
3. If there are changes, commit with a descriptive Conventional Commits message (feat/fix/chore/docs/refactor) and push to origin
4. If no changes, report "已是最新，無需同步" / "Already up to date, nothing to sync"
5. Report the sync result with the commit hash and push status

If the user says "pull" or "拉", run `cd ~/.claude && git pull --rebase origin main` instead to pull latest from remote.

After pull, scan for cross-machine tasks:
1. List files in `~/.claude/cross-machine/pending/` (ignore `.gitkeep`)
2. For each `.md` file, check if a file with the same name exists in `~/.claude/cross-machine/done/`
3. If it exists in done/ → skip (already completed on this machine)
4. If it doesn't exist in done/ → it's a new task, show it to the user
5. Present new tasks as a list with task name and one-line description from the "Goal"/"目標" section
6. If user says to execute a task, read the full task file, adapt to the local OS/tools, and execute
7. After completing a task, copy the file to `~/.claude/cross-machine/done/` with added completion info (completed_by, completed_at, summary of what was done)
8. If no new tasks, report "無新任務" / "No new tasks"

Notes:
- The Git repo at `~/.claude/` is the single source of truth for cross-machine sync
- `.gitignore` excludes session data, plugins, cache, and machine-specific files
- Never commit `settings.local.json` or files under `projects/`, `sessions/`, `plugins/`
