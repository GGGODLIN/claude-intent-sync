---
task: setup-cron-backup
from: example-origin (darwin)
created: 2026-04-15
status: pending
---

## Goal

Set up a daily scheduled task that backs up important data to a remote location.

## Requirements

- Runs daily at 2am local time
- Executes a backup script that commits and pushes a git repo
- Logs output to a file for later inspection
- Handles sync conflicts gracefully (pull --rebase before push)

## Reference: How it was done on macOS

Script at `~/backup.sh`:
```bash
#!/bin/bash
cd ~/my-data-repo || exit 1
git add -A
if ! git diff --cached --quiet; then
  git commit -m "chore: daily backup $(date +%Y-%m-%d) $(hostname -s)"
  git pull --rebase origin main
  git push origin main
fi
```

Crontab entry:
```
0 2 * * * ~/backup.sh >> ~/backup.log 2>&1
```

## Cross-platform notes

- **macOS/Linux**: use `crontab -e` to add the schedule, or `launchd` plist for macOS persistence
- **Windows**: use Task Scheduler (`schtasks /create`) or a PowerShell scheduled job
- Path format differs: `~/backup.sh` → `%USERPROFILE%\backup.ps1` on Windows
- The backup script itself needs to be rewritten in PowerShell for Windows
- Git credentials must be configured on each machine (e.g., `gh auth login` or credential manager)
