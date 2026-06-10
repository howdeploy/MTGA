---
description: Turn ON Make Text Great Again — Trump-style chat replies + spinner phrases
argument-hint: "[ru|en]"
allowed-tools: Bash(bash:*)
---

MTGA toggle result:

!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/mtga.sh" on $ARGUMENTS`

Relay the result above to the user in their language. Always mention:

- The chat style and spinner phrases take effect after `/clear` or a session restart.
- Commit messages stay normal by default — enable them separately with `/mtga:commits on`.
- Turn everything off with `/mtga:off` (previous settings are restored from backup).
