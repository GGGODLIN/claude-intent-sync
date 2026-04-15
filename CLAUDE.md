# sync-claude-config Plugin

Cross-machine Claude Code config sync methodology. Dispatches OS-specific setup as tasks adapted by AI on each machine.

## Commands

- `/sync-claude-config:push` — Stage, check for OS-specific changes, commit, and push to the user's private config repo
- `/sync-claude-config:pull` — Pull latest and scan for pending cross-machine tasks
- `/sync-claude-config:setup` — First-time setup: Primary (bootstrap new) or Secondary (connect existing)

## Onboarding behavior

When this plugin is installed but not yet initialized (the marker file `~/.claude/cross-machine/.initialized` does not exist), proactively offer to run `/sync-claude-config:setup` at the end of your next response to the user. Do this only once per session. The marker is created by `:setup` on successful completion, which suppresses further prompts.

Do not offer setup when:
- The marker file exists
- The user has explicitly declined earlier in the session
- The user's current task is unrelated and would be interrupted (use judgment)

## Cross-machine task generation

After completing OS-specific operations (plugin install, cron/scheduled tasks, shell scripts, `settings.local.json` edits, OS-specific tools like `launchd`/`homebrew`/`systemd`/`Task Scheduler`), proactively ask the user "Sync this to your other machine?" If yes, write a task `.md` file to `~/.claude/cross-machine/pending/` following `~/.claude/cross-machine/README.md`.

Pure config file changes (settings.json, CLAUDE.md, files under skills/commands/rules) sync via git directly — no task needed.
