# claude-intent-sync

**Sync intent, not files.** A Claude Code methodology for cross-machine config sync where OS-specific setup is dispatched as tasks and adapted by AI on each machine.

## The Problem

Syncing Claude Code config (`~/.claude/`) across machines with traditional dotfile tools (chezmoi, stow, yadm) works for text files but breaks for:

- Plugin installations (`/install-plugin` has no corresponding file)
- Scheduled tasks (cron on macOS/Linux, Task Scheduler on Windows)
- Shell scripts (bash vs PowerShell)
- OS-specific binaries and paths
- Tool installations (brew vs apt vs winget)

These require per-OS `{{ if eq .os "darwin" }}...{{ end }}` templating that quickly becomes unmaintainable.

## The Idea

Instead of syncing files, sync **tasks describing what should be true** — then let Claude on each target machine adapt the approach to its local environment.

```
~/.claude/cross-machine/
├── pending/    ← tasks dispatched from origin machine
└── done/       ← completion log (per-machine)
```

### Flow

```
Machine A (origin)
  → Claude completes an OS-specific setup
  → Claude proactively asks: "Sync this to your other machine?"
  → Writes a task .md to pending/
  → git push

Machine B (target)
  → git pull
  → /sync pull triggers scan of pending/ vs done/
  → Lists new tasks with descriptions
  → User says "execute"
  → Claude reads task, adapts for local OS, executes
  → Copies to done/ with completion summary
```

## Install

```bash
git clone https://github.com/GGGODLIN/claude-intent-sync.git /tmp/cis
bash /tmp/cis/install.sh
```

This installs the `/sync` skill, creates `cross-machine/pending/` and `done/`, and adds a `.gitignore` template to `~/.claude/`.

After installation, follow the printed steps to create your own private Git repo for `~/.claude/` and wire up your other machines.

## Usage

**Push changes** (from the machine you just configured):
```
/sync-claude-setting-cross-platform
```

**Pull and execute pending tasks** (on the target machine):
```
/sync-claude-setting-cross-platform pull
```

The skill will scan `pending/`, compare with `done/`, and present new tasks. You decide which to execute.

**Create a task manually** by writing a `.md` file in `~/.claude/cross-machine/pending/` following [`templates/task-template.md`](templates/task-template.md).

## Examples

- [`examples/install-plugins.md`](examples/install-plugins.md) — cross-machine Claude Code plugin installation
- [`examples/setup-cron-backup.md`](examples/setup-cron-backup.md) — scheduled backup that adapts to crontab / Task Scheduler
- [`examples/install-mcp-server.md`](examples/install-mcp-server.md) — MCP server install with path / package manager adaptation

## What gets synced vs not

### Synced via git (`~/.claude/`)
- `CLAUDE.md`
- `settings.json`
- `skills/`, `commands/`, `rules/`, `agents/`, `hooks/`, `scripts/`
- `cross-machine/pending/`, `cross-machine/done/`

### NOT synced (excluded via `.gitignore`)
- `settings.local.json` (machine-specific, may contain secrets)
- `projects/`, `sessions/`, `session-env/` (private conversation data)
- `plugins/` (installed via task on each machine)
- `cache/`, `telemetry/`, `statsig/`, etc. (runtime state)

See [`templates/gitignore.template`](templates/gitignore.template) for the full list.

## Integration with other dotfile tools

This framework is git-based and works standalone. You can combine it with:
- **chezmoi**: point chezmoi at your personal config repo
- **stow / yadm**: treat `~/.claude/` as one managed directory
- **Dropbox / iCloud**: skip git entirely, use cloud sync

The core mechanism is `pending/` + `done/` + the `/sync` skill. Everything else is optional.

## License

MIT

## Credits

Developed through dogfooding with Claude Code on a Mac+Windows setup.
