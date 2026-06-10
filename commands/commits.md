---
description: Toggle Trump-style git commit messages (separate from the chat style)
argument-hint: "on|off"
allowed-tools: Bash(bash:*)
---

MTGA commits toggle result:

!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/mtga.sh" commits $ARGUMENTS`

Relay the result above to the user in their language. Notes:

- This flag takes effect immediately (no restart needed), but it only matters while the MTGA style is ON (`/mtga:on`).
- `on` → commit messages are written as dramatic Trump-style tweets (technical meaning preserved).
- `off` → commit messages stay normal conventional commits, even while the chat style is on.
