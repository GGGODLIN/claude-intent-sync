Pull latest from the user's private config repo and scan for cross-machine tasks.

## Preflight — onboarding fallback

Check for `~/.claude/cross-machine/.initialized`. If it does not exist, tell the user this plugin is not yet initialized and defer to the `setup` command. Do not proceed with pull.

## Steps

1. Run `cd ~/.claude && git pull --rebase origin main`
2. After pull, scan for cross-machine tasks:
   - List files in `~/.claude/cross-machine/pending/` (ignore `.gitkeep`)
   - For each `.md` file, check whether a same-named file exists in `~/.claude/cross-machine/done/`
   - If exists in `done/` → skip (already completed on this or another machine)
   - If not in `done/` → present as a new task with name and one-line goal extracted from the task file
3. If the user wants to execute a task:
   - Read the full task file (and `~/.claude/cross-machine/README.md` for execution guidance)
   - Adapt to the local OS, package manager, and conventions
   - Execute, verifying end state matches the Goal
   - Copy the task file to `~/.claude/cross-machine/done/<name>.md` with appended completion frontmatter (`completed_by`, `completed_at`) and an Execution summary section
4. If no new tasks, report "無新任務" / "No new tasks"

## Notes

- For details on writing and executing tasks, read `~/.claude/cross-machine/README.md`.
- The sync mechanism is described in the plugin README.
