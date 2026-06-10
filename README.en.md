# MTGA — MAKE TEXT GREAT AGAIN

A Claude Code plugin that makes Claude reply in the style of Donald Trump tweets. CAPS. Exclamations. Self-praise. In every chat reply — not just commits.

> The best plugin in the history of plugins. Everybody says so.

🇷🇺 [Русская версия README](README.md)

Inspired by [MowoGroup/MCGA](https://github.com/MowoGroup/MCGA) (Make Commits Great Again), which does this for commit messages. MTGA takes the idea to the whole conversation — and keeps commits as a separate toggle, off by default.

---

## What you get

1. **Output styles** (`MTGA` for Russian, `MTGA-EN` for English) — Claude answers, reports, and explains in Trump-tweet style, while file paths, line numbers, test results, and honesty stay fully intact. The style applies ONLY to chat text: code, files, docs, and commands are never touched.
2. **100 spinner phrases** (RU + EN packs) — the status lines at the bottom turn into things like "Building a wall of tests — bugs will pay for it" and "I have concepts of a plan".
3. **Toggles for everything** — the style, the spins, and Trump-style commits switch on/off independently. Your previous `outputStyle` and `spinnerVerbs` are backed up and restored.

## Example

**Plain Claude:**

> I fixed the token check in auth/middleware.js — it ran after the redirect. All 14 tests pass.

**MTGA Claude:**

> Bug found. Bug DESTROYED.
>
> In `auth/middleware.js:47` the token was checked AFTER the redirect. For years. I moved the check before the redirect. Three lines. The best three lines in that file. Tests passed — all 14, zero red.
>
> HUGE WIN!

## Installation

```
/plugin marketplace add howdeploy/MTGA
/plugin install mtga@mtga
```

Then:

```
/mtga:on        # Russian style + spins
/mtga:on en     # English style + spins
```

## Commands

| Command | What it does |
| --- | --- |
| `/mtga:on [ru\|en]` | Enable the chat style + spinner phrases (backs up your previous settings) |
| `/mtga:off` | Disable everything, restore previous `outputStyle` and `spinnerVerbs` |
| `/mtga:status` | Show what's on: style, language, commits, spins |
| `/mtga:commits on\|off` | Trump-style **commit messages** — separate opt-in, off by default |
| `/mtga:spins on\|off [ru\|en]` | Spinner phrases only, independent from the chat style |

Style and spinner changes take effect after `/clear` or a new session (Claude Code reads them at session start). The commits flag works immediately.

## How it works

- The chat style is a regular Claude Code [output style](https://docs.claude.com/en/docs/claude-code/output-styles) shipped in `output-styles/`. `/mtga:on` sets `outputStyle` in `~/.claude/settings.json`.
- Spins are written into the `spinnerVerbs` setting (`mode: replace`). Your previous phrases are saved to `~/.claude/mtga-state.json` and restored on `off`.
- The commits toggle is a flag in `~/.claude/mtga-state.json`; the output style instructs Claude to check it before writing any commit message. `false` → normal conventional commits, no exceptions.

## Requirements

- Claude Code with plugin support
- `bash` + `python3` (Linux, macOS; on Windows use WSL or Git Bash)

## Uninstalling

Run `/mtga:off` **before** uninstalling the plugin — it restores your original `outputStyle` and `spinnerVerbs`. If you forgot: remove the `outputStyle` and `spinnerVerbs` keys from `~/.claude/settings.json` (or restore them from `~/.claude/mtga-state.json`) and delete `~/.claude/mtga-state.json`.

## License

[MIT](LICENSE) © 2026 howdeploy. Inspired by [MowoGroup/MCGA](https://github.com/MowoGroup/MCGA) (MIT).
