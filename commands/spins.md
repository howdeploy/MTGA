---
description: Toggle MTGA spinner phrases (Trump-style status lines) separately
argument-hint: "on|off [ru|en]"
allowed-tools: Bash(bash:*)
---

MTGA spins toggle result:

!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/mtga.sh" spins $ARGUMENTS`

Relay the result above to the user in their language. Notes:

- `on` → replaces `spinnerVerbs` in `~/.claude/settings.json` with the MTGA phrase pack (the previous value is backed up and restored on `off`).
- Spinner changes take effect in a new session.
- This is independent from the chat style: you can run spins without `/mtga:on` and vice versa.
