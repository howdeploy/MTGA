#!/usr/bin/env bash
# MTGA — MAKE TEXT GREAT AGAIN. Toggle script.
# Usage: mtga.sh on [ru|en] | off | status | commits on|off | spins on|off [ru|en]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export MTGA_PLUGIN_ROOT="${MTGA_PLUGIN_ROOT:-$(dirname "$SCRIPT_DIR")}"
export MTGA_SETTINGS="${MTGA_SETTINGS:-$HOME/.claude/settings.json}"
export MTGA_STATE="${MTGA_STATE:-$HOME/.claude/mtga-state.json}"

PY=""
for cand in python3 python; do
  if command -v "$cand" >/dev/null 2>&1; then PY="$cand"; break; fi
done
if [ -z "$PY" ]; then
  echo "ERROR: python3 is required for MTGA commands." >&2
  exit 1
fi

exec "$PY" - "$@" <<'PYEOF'
import json
import os
import sys

SETTINGS_PATH = os.environ["MTGA_SETTINGS"]
STATE_PATH = os.environ["MTGA_STATE"]
PLUGIN_ROOT = os.environ["MTGA_PLUGIN_ROOT"]

STYLE_NAME = {"ru": "MTGA", "en": "MTGA-EN"}
DEFAULT_STATE = {"style": "off", "commits": False, "spins": False, "lang": "ru", "backup": {}}


def load(path, default):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return default
    except json.JSONDecodeError as e:
        sys.exit(f"ERROR: {path} is not valid JSON ({e}). Nothing was changed, fix the file first.")


def save(path, data):
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")
    os.replace(tmp, path)


def verbs_for(lang):
    path = os.path.join(PLUGIN_ROOT, "spins", f"{lang}.json")
    with open(path, encoding="utf-8") as f:
        verbs = json.load(f)
    if not isinstance(verbs, list) or not verbs:
        sys.exit(f"ERROR: {path} must be a non-empty JSON array of phrases.")
    return verbs


settings = load(SETTINGS_PATH, {})
state = {**DEFAULT_STATE, **load(STATE_PATH, {})}

args = sys.argv[1:]
cmd = args[0] if args else "status"


def lang_arg(index, default):
    value = args[index] if len(args) > index else default
    if value not in STYLE_NAME:
        sys.exit(f"ERROR: unknown language '{value}'. Use: ru | en")
    return value


def spins_on(lang):
    if not state["spins"]:
        state["backup"]["spinnerVerbs_present"] = "spinnerVerbs" in settings
        state["backup"]["spinnerVerbs"] = settings.get("spinnerVerbs")
    settings["spinnerVerbs"] = {"mode": "replace", "verbs": verbs_for(lang)}
    state["spins"] = True


def spins_off():
    if state["spins"]:
        if state["backup"].get("spinnerVerbs_present"):
            settings["spinnerVerbs"] = state["backup"]["spinnerVerbs"]
        else:
            settings.pop("spinnerVerbs", None)
    state["spins"] = False


def style_on(lang):
    if state["style"] != "on":
        state["backup"]["outputStyle_present"] = "outputStyle" in settings
        state["backup"]["outputStyle"] = settings.get("outputStyle")
    settings["outputStyle"] = STYLE_NAME[lang]
    state["style"] = "on"
    state["lang"] = lang


def style_off():
    if state["style"] == "on":
        if state["backup"].get("outputStyle_present"):
            settings["outputStyle"] = state["backup"]["outputStyle"]
        else:
            settings.pop("outputStyle", None)
    state["style"] = "off"


changed = True

if cmd == "on":
    lang = lang_arg(1, state.get("lang", "ru"))
    style_on(lang)
    spins_on(lang)
    count = len(settings["spinnerVerbs"]["verbs"])
    print(f"MTGA is ON (lang={lang}). outputStyle={settings['outputStyle']}, spinner phrases replaced ({count} items), previous values backed up.")
    print("Takes effect after /clear or a new session. Commits stay normal unless /mtga:commits on.")
elif cmd == "off":
    style_off()
    spins_off()
    print("MTGA is OFF. outputStyle and spinnerVerbs restored from backup.")
    print("Takes effect after /clear or a new session.")
elif cmd == "commits":
    sub = args[1] if len(args) > 1 else None
    if sub == "on":
        state["commits"] = True
        print("MTGA commits: ON. Commit messages will be Trump-styled (effective immediately, while MTGA style is ON).")
    elif sub == "off":
        state["commits"] = False
        print("MTGA commits: OFF. Commit messages stay normal conventional commits.")
    else:
        changed = False
        print(f"MTGA commits is {'ON' if state['commits'] else 'OFF'}. Usage: /mtga:commits on|off")
elif cmd == "spins":
    sub = args[1] if len(args) > 1 else None
    if sub == "on":
        lang = lang_arg(2, state.get("lang", "ru"))
        spins_on(lang)
        count = len(settings["spinnerVerbs"]["verbs"])
        print(f"MTGA spins: ON (lang={lang}, {count} phrases). Previous spinnerVerbs backed up. Takes effect in a new session.")
    elif sub == "off":
        spins_off()
        print("MTGA spins: OFF. Previous spinnerVerbs restored. Takes effect in a new session.")
    else:
        changed = False
        print(f"MTGA spins is {'ON' if state['spins'] else 'OFF'}. Usage: /mtga:spins on|off [ru|en]")
elif cmd == "status":
    changed = False
    print(json.dumps({
        "style": state["style"],
        "lang": state["lang"],
        "commits": "on" if state["commits"] else "off",
        "spins": "on" if state["spins"] else "off",
        "outputStyle_setting": settings.get("outputStyle"),
        "spinnerVerbs_count": len((settings.get("spinnerVerbs") or {}).get("verbs", [])),
    }, ensure_ascii=False, indent=2))
else:
    sys.exit(f"ERROR: unknown command '{cmd}'. Use: on [ru|en] | off | status | commits on|off | spins on|off [ru|en]")

if changed:
    save(SETTINGS_PATH, settings)
    save(STATE_PATH, state)
PYEOF
