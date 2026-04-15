# claude-intent-sync

**Sync intent, not files.** A Claude Code methodology for cross-machine config sync where OS-specific setup is dispatched as tasks and adapted by AI on each machine.

> **New user?** Skip to [Bootstrap](#bootstrap). Open Claude Code, paste the prompt, and let Claude handle the setup.

---

## The Problem

Syncing Claude Code config (`~/.claude/`) across machines works fine for text files but breaks for:

- Plugin installations (`/install-plugin` has no corresponding file)
- Scheduled tasks (cron-like, varies by OS)
- Shell scripts (different shells across OS)
- OS-specific binaries and paths
- Tool installations (different package managers)

Traditional dotfile sync approaches require per-OS conditional templating, which becomes unmaintainable as the divergence grows.

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

---

## Bootstrap

### Prerequisites

- [Claude Code](https://claude.com/claude-code) installed
- `git` installed
- A GitHub account (or any Git host)
- Authenticated GitHub access — easiest via [`gh` CLI](https://cli.github.com/):
  ```bash
  gh auth login
  ```
  Without `gh`, Claude will guide you to create the repo manually on github.com.

### Run it

Open Claude Code on the machine you want to set up, and paste:

> Please read https://github.com/GGGODLIN/claude-intent-sync/blob/main/README.md and help me set up cross-machine sync on this machine.

Claude will then follow the instructions below.

---

## Instructions for Claude

If you are Claude Code reading this README to set up a machine, follow these steps:

### Step 1 — Ask the user which mode

Ask: **"Is this your FIRST machine setting up cross-machine sync (Primary), or a SECONDARY machine connecting to an existing setup?"**

Then proceed to the matching section.

### Primary machine (first-time setup)

1. **Clone this framework to a temp location:**
   ```bash
   git clone https://github.com/GGGODLIN/claude-intent-sync.git /tmp/claude-intent-sync
   ```

2. **Run install.sh:**
   ```bash
   bash /tmp/claude-intent-sync/install.sh
   ```
   This installs the `/sync` skill into `~/.claude/commands/`, creates `~/.claude/cross-machine/{pending,done}/`, and adds a `.gitignore` template to `~/.claude/` if none exists.

3. **Add the cross-machine sync section to the user's `~/.claude/CLAUDE.md`:**
   Read `/tmp/claude-intent-sync/templates/CLAUDE.md.snippet` and append it to `~/.claude/CLAUDE.md`. If CLAUDE.md doesn't exist, create it from the snippet.

4. **Help the user create their private config repo:**
   - Ask for a repo name (suggest `claude-config`)
   - First check if `gh` is available and authenticated: `gh auth status`
   - If yes, use `gh repo create <name> --private`
   - If no, prompt the user to run `gh auth login` first, OR walk them through creating the repo manually on https://github.com/new
   - Recommend keeping it private — `~/.claude/` may contain non-secret but personal settings

5. **Initialize git in `~/.claude/` and push:**
   ```bash
   cd ~/.claude
   git init
   git branch -M main
   git remote add origin <the repo URL>
   git add -A
   git commit -m "chore: initial config"
   git push -u origin main
   ```

6. **Confirm success and tell the user:**
   - Their private config repo URL (they'll need this for secondary machines)
   - Next step: on other machines, run the same bootstrap prompt and choose "Secondary"

### Secondary machine (connecting to existing setup)

1. **Ask the user for their private config repo URL** (the one created on their primary machine). Expected format: `https://github.com/username/repo.git` or `git@github.com:username/repo.git`.

2. **Back up existing `~/.claude/` if it has content:**
   ```bash
   if [ -d ~/.claude ] && [ "$(ls -A ~/.claude)" ]; then
     mv ~/.claude ~/.claude-backup-$(date +%Y%m%d-%H%M%S)
   fi
   ```

3. **Clone the private config repo:**
   ```bash
   git clone <user's repo URL> ~/.claude
   ```
   This brings over the `/sync` skill, `cross-machine/` directory, `.gitignore`, and all the user's synced config.

4. **Tell the user to restart Claude Code** so it picks up the new skills and commands in `~/.claude/`.

5. **After restart, the user runs `/sync pull`** to scan for pending cross-machine tasks. From there, the `/sync` skill takes over.

---

## Usage (after setup)

**Push changes** (from the machine you just configured):
```
/sync-claude-setting-cross-platform
```

**Pull and execute pending tasks** (on any other machine):
```
/sync-claude-setting-cross-platform pull
```

The skill scans `pending/`, compares with `done/`, and presents new tasks. You decide which to execute.

**Create a task manually** by writing a `.md` file in `~/.claude/cross-machine/pending/` following [`templates/task-template.md`](templates/task-template.md).

---

## Current Limitations

The framework is currently designed for a **primary/secondary** workflow — typically one origin machine dispatching tasks to one or more target machines. While the underlying Git mechanism is symmetric (any machine with push access can write tasks), the task model has gaps when used in a fully bidirectional / mesh fashion:

- **No machine targeting** — A task in `pending/` is visible to every machine that pulls. There is no `to:` field to scope a task to a specific host. Every pulling machine will be asked whether to execute it.
- **`done/` is shared, not per-machine** — When machine A executes a task and pushes its `done/X.md`, machine B will then see `X.md` as already done locally and skip it, even if B was the intended target.
- **`/sync` push does not pre-pull** — Concurrent pushes from two machines that touch the same file will be rejected at the second push and require manual rebase.

For the typical primary→secondary flow (one machine dispatches, others receive), none of these are a problem. They only surface when two or more machines actively dispatch tasks to each other.

## How task generation is triggered

The framework uses **two complementary triggers** to catch when a task should be created:

1. **In-context trigger (primary)** — Whenever Claude completes an OS-specific operation (plugin install, scheduled task setup, shell script, machine-specific config edit), it proactively asks the user "Sync this to your other machine?" The trigger logic is installed via `templates/CLAUDE.md.snippet` into the user's `CLAUDE.md`, so it stays loaded in every session.

2. **Push-time check (safety net)** — When `/sync` push runs, it inspects the staged file paths for OS-specific patterns (new shell scripts, edits to hook directories, etc.) and prompts the user before committing. This catches cases the in-context trigger missed. No extra LLM call — it reuses the diff Claude already reads.

The in-context trigger is fast and accurate when Claude has full context. The push-time check is the safety net for missed cases. Together they reduce both false negatives (forgotten tasks) and the cost of detecting them.

## Roadmap

- **Mesh / decentralized task flow** — Add `to:` field to task frontmatter for machine targeting, switch `done/` to a per-host structure (e.g., `done/{hostname}/X.md`), and have `/sync` push perform `git pull --rebase` first. These together will allow any machine to safely dispatch tasks to any other machine in a peer-to-peer fashion.
- **Linux examples** — More OS-specific example tasks (currently the bundled examples lean toward macOS).
- **Conflict diagnostics** — Better error messages when `/sync` push fails due to remote divergence.

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

## License

MIT

## Credits

Developed through dogfooding Claude Code across multiple machines.
