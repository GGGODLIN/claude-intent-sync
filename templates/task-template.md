---
task: <short-name>
from: <hostname> (<os>)
created: YYYY-MM-DD
status: pending
---

## Goal / 目標

One-sentence description of what this task should accomplish on the target machine.

## Requirements / 需求

- Concrete requirements (e.g., "install plugin X", "set up cron job that runs daily at 2am")
- What external resources it needs (e.g., "uses repo at github.com/user/backup")
- What the end state should look like

## Reference: How it was done on the origin machine / 起源機器的做法（參考，不要照抄）

Describe how this was done on the machine that created the task — as a reference, not a prescription. The target machine should adapt to its own OS, package manager, and conventions.

Example:
```
# Origin used <scheduler> with <invocation>
# Target should pick the equivalent scheduler available locally
```

## Cross-platform notes / 跨平台注意

Explicitly flag things that will need adaptation:
- OS-specific tools (crontab vs Task Scheduler vs systemd)
- Path format differences
- Package manager differences (brew vs apt vs winget)
- Credential / auth setup specifics
