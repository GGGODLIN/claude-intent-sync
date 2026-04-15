---
task: install-plugins
from: example-origin (darwin)
created: 2026-04-15
status: pending
---

## Goal

Install the Claude Code plugins I use on the origin machine.

## Requirements

- Install these plugins:
  - `superpowers@claude-plugins-official` — core workflows (brainstorming, TDD, debugging, plans, code review)
  - `frontend-design@claude-plugins-official` — UI design patterns
  - `codex@openai-codex` — OpenAI Codex integration

## Reference: How to install on any machine

In Claude Code, run:
```
/install-plugin superpowers
/install-plugin frontend-design
/install-plugin codex
```

## Cross-platform notes

- Plugins install into `~/.claude/plugins/` regardless of OS (path format adjusted automatically by Claude Code)
- `codex` plugin requires OpenAI API key to be set — prompt the user if missing
- Network access required to plugin registry
