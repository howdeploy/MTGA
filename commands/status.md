---
description: Show MTGA status — style, language, commits, spins
allowed-tools: Bash(bash:*)
---

Current MTGA state:

!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/mtga.sh" status`

Present this state to the user in their language in a compact, readable form: style on/off (+ language), commits on/off, spins on/off (+ phrase count).

Then list the available commands: `/mtga:on [ru|en]`, `/mtga:off`, `/mtga:commits on|off`, `/mtga:spins on|off [ru|en]`.
