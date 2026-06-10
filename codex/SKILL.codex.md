---
name: mtga
description: MAKE TEXT GREAT AGAIN — toggle Trump-style chat replies for Codex. Use when the user types $mtga, or asks to enable/disable/check MTGA or Trump style. Arguments are on [ru|en], off, or status.
---

# MTGA toggle for Codex

Run the bundled script with the user's arguments and relay its output:

```
bash ~/.codex/skills/mtga/scripts/mtga-codex.sh <on [ru|en] | off | status>
```

- `on [ru|en]` — insert the MTGA style block into `~/.codex/AGENTS.md` (default language: ru; running it again switches the language).
- `off` — remove the MTGA style block and this skill from `~/.codex/skills/mtga/` (full cleanup).
- `status` — show whether the block is present and which language is active.

After relaying the result, always mention: changes to `~/.codex/AGENTS.md` take effect in a NEW Codex session.

Do not edit `~/.codex/AGENTS.md` manually — only the script touches it, and only the block between the `<!-- MTGA:BEGIN -->` and `<!-- MTGA:END -->` markers.
