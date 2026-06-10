#!/usr/bin/env bash
# MTGA — Codex CLI integration. Manages the MTGA style block in ~/.codex/AGENTS.md
# and the $mtga skill in ~/.codex/skills/mtga/.
# Self-contained: works both from the plugin (scripts/ + ../codex/) and from the
# installed skill copy (scripts/ + ../references/).
# Usage: mtga-codex.sh on [ru|en] | off | status
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export MTGA_CODEX_AGENTS="${MTGA_CODEX_AGENTS:-$HOME/.codex/AGENTS.md}"
export MTGA_CODEX_SKILL_DIR="${MTGA_CODEX_SKILL_DIR:-$HOME/.codex/skills/mtga}"
export MTGA_CODEX_SELF="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"

# Style sources: plugin layout (../codex/) or installed-skill layout (../references/)
if [ -d "$SCRIPT_DIR/../codex" ]; then
  export MTGA_CODEX_STYLES="$(cd "$SCRIPT_DIR/../codex" && pwd)"
  export MTGA_CODEX_SKILL_MD="$MTGA_CODEX_STYLES/SKILL.codex.md"
elif [ -d "$SCRIPT_DIR/../references" ]; then
  export MTGA_CODEX_STYLES="$(cd "$SCRIPT_DIR/../references" && pwd)"
  export MTGA_CODEX_SKILL_MD="$(cd "$SCRIPT_DIR/.." && pwd)/SKILL.md"
else
  echo "ERROR: style files not found next to the script (expected ../codex or ../references)." >&2
  exit 1
fi

PY=""
for cand in python3 python; do
  if command -v "$cand" >/dev/null 2>&1; then PY="$cand"; break; fi
done
if [ -z "$PY" ]; then
  echo "ERROR: python3 is required for MTGA commands." >&2
  exit 1
fi

exec "$PY" - "$@" <<'PYEOF'
import os
import re
import shutil
import sys

AGENTS_PATH = os.environ["MTGA_CODEX_AGENTS"]
SKILL_DIR = os.environ["MTGA_CODEX_SKILL_DIR"]
STYLES_DIR = os.environ["MTGA_CODEX_STYLES"]
SKILL_MD_SRC = os.environ["MTGA_CODEX_SKILL_MD"]
SELF_PATH = os.environ["MTGA_CODEX_SELF"]

BEGIN_RE = re.compile(r"^<!-- MTGA:BEGIN( lang=(?P<lang>\w+))? -->$", re.M)
END_RE = re.compile(r"^<!-- MTGA:END -->$", re.M)

LANGS = ("ru", "en")


def style_file(lang):
    for name in (f"MTGA.codex.{lang}.md", f"{lang}.md"):
        path = os.path.join(STYLES_DIR, name)
        if os.path.exists(path):
            return path
    sys.exit(f"ERROR: style file for '{lang}' not found in {STYLES_DIR}.")


def read_agents():
    try:
        with open(AGENTS_PATH, encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        return ""


def write_agents(text):
    os.makedirs(os.path.dirname(AGENTS_PATH) or ".", exist_ok=True)
    tmp = AGENTS_PATH + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(text)
    os.replace(tmp, AGENTS_PATH)


def find_block(text):
    """Returns (start, end, lang) of the marked block incl. markers, or None.
    Exits with an error if markers are corrupted."""
    begins = list(BEGIN_RE.finditer(text))
    ends = list(END_RE.finditer(text))
    if not begins and not ends:
        return None
    if len(begins) != 1 or len(ends) != 1 or begins[0].start() >= ends[0].start():
        sys.exit(
            f"ERROR: MTGA markers in {AGENTS_PATH} are corrupted "
            f"({len(begins)} BEGIN, {len(ends)} END). Fix the file manually, nothing was changed."
        )
    return begins[0].start(), ends[0].end(), begins[0].group("lang")


def copy_file(src, dst):
    """Copy unless src and dst are already the same file (running from the installed skill)."""
    if os.path.exists(dst) and os.path.samefile(src, dst):
        return
    shutil.copy(src, dst)


def install_skill():
    os.makedirs(os.path.join(SKILL_DIR, "scripts"), exist_ok=True)
    os.makedirs(os.path.join(SKILL_DIR, "references"), exist_ok=True)
    copy_file(SKILL_MD_SRC, os.path.join(SKILL_DIR, "SKILL.md"))
    script_dst = os.path.join(SKILL_DIR, "scripts", "mtga-codex.sh")
    copy_file(SELF_PATH, script_dst)
    os.chmod(script_dst, 0o755)
    for lang in LANGS:
        copy_file(style_file(lang), os.path.join(SKILL_DIR, "references", f"MTGA.codex.{lang}.md"))


def remove_skill():
    if os.path.isdir(SKILL_DIR):
        shutil.rmtree(SKILL_DIR)
        return True
    return False


args = sys.argv[1:]
cmd = args[0] if args else "status"

if cmd == "on":
    lang = args[1] if len(args) > 1 else "ru"
    if lang not in LANGS:
        sys.exit(f"ERROR: unknown language '{lang}'. Use: ru | en")
    with open(style_file(lang), encoding="utf-8") as f:
        style = f.read().rstrip("\n")
    block = f"<!-- MTGA:BEGIN lang={lang} -->\n{style}\n<!-- MTGA:END -->"
    text = read_agents()
    found = find_block(text)
    if found:
        start, end, _ = found
        text = text[:start] + block + text[end:]
        action = "replaced"
    else:
        if text and not text.endswith("\n"):
            text += "\n"
        if text:
            text += "\n"
        text += block + "\n"
        action = "added"
    write_agents(text)
    install_skill()
    print(f"MTGA codex: ON (lang={lang}). Style block {action} in {AGENTS_PATH}; $mtga skill installed at {SKILL_DIR}.")
    print("Takes effect in a NEW Codex session. Inside Codex use: $mtga on|off|status.")
elif cmd == "off":
    text = read_agents()
    found = find_block(text)
    removed = []
    if found:
        start, end, _ = found
        before = text[:start].rstrip("\n")
        after = text[end:].lstrip("\n")
        if before and after:
            text = before + "\n\n" + after
        else:
            text = before + ("\n" if before else "") + after
        write_agents(text)
        removed.append(f"style block removed from {AGENTS_PATH}")
    if remove_skill():
        removed.append(f"$mtga skill removed from {SKILL_DIR}")
    if removed:
        print("MTGA codex: OFF — " + "; ".join(removed) + ".")
        print("Takes effect in a NEW Codex session.")
    else:
        print("MTGA codex: already OFF — nothing to remove.")
elif cmd == "status":
    found = find_block(read_agents())
    skill = os.path.isdir(SKILL_DIR)
    if found:
        print(f"MTGA codex: ON (lang={found[2] or 'ru'}), $mtga skill {'installed' if skill else 'MISSING'}.")
    else:
        print(f"MTGA codex: OFF{', but $mtga skill is still installed' if skill else ''}.")
else:
    sys.exit(f"ERROR: unknown command '{cmd}'. Use: on [ru|en] | off | status")
PYEOF
