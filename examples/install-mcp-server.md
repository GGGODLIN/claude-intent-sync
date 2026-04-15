---
task: install-mcp-server
from: example-origin (darwin)
created: 2026-04-15
status: pending
---

## Goal

Install and configure an MCP server (e.g., a memory system, browser automation, or API integration) on the target machine.

## Requirements

- Install the MCP server package (usually via a package manager)
- Register it in `~/.claude/settings.local.json` under `mcpServers`
- Configure any hooks or environment variables it needs

## Reference: Example — installing the MemPalace MCP server on macOS

```bash
# Install
uv tool install mempalace@git+https://github.com/MemPalace/mempalace.git

# Initialize
mempalace init ~/.claude --yes
```

Add to `~/.claude/settings.local.json`:
```json
{
  "mcpServers": {
    "mempalace": {
      "command": "/Users/you/.local/share/uv/tools/mempalace/bin/python3",
      "args": ["-m", "mempalace.mcp_server"]
    }
  }
}
```

## Cross-platform notes

- Package manager differs: `brew` (macOS) / `apt` (Debian) / `winget` or `choco` (Windows)
- Python / Node / Go may already be installed or need to be installed first
- Binary path format differs across OS
- `settings.local.json` is machine-specific and NOT synced via git — each machine configures its own
