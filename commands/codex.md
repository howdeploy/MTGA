---
description: Toggle Trump style for OpenAI Codex CLI (style block in ~/.codex/AGENTS.md + $mtga skill)
argument-hint: "on|off [ru|en]"
allowed-tools: Bash(bash:*)
---

MTGA codex toggle result:

!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/mtga.sh" codex $ARGUMENTS`

Relay the result above to the user in their language. Notes:

- `on [ru|en]` inserts a marked MTGA style block into `~/.codex/AGENTS.md` (only the block between `<!-- MTGA:BEGIN -->` / `<!-- MTGA:END -->` is ever touched — the rest of the file stays intact) and installs the `$mtga` skill into `~/.codex/skills/mtga/`, so the user can toggle from inside Codex with `$mtga on|off|status`.
- `off` removes both the block and the skill.
- Codex picks up `AGENTS.md` changes in a NEW Codex session.
- This is a separate opt-in: `/mtga:on` does not touch Codex, but `/mtga:off` (the full reset) also turns the Codex part off.
