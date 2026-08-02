#!/usr/bin/env bash
# iterm-herdr-cmd-keys.sh — route macOS ⌘ chords into herdr (2026-07-06)
#
# WHY: herdr is now the whole terminal life, so ⌘1..9 should drive herdr TABS
# (not iTerm2 tabs) and ⌘⇧[/]/⌘⇧j/k should cycle herdr tabs/workspaces. iTerm2
# normally eats ⌘, so we add a SURGICAL per-chord mapping that forwards ONLY these
# 13 chords to herdr as their Kitty-keyboard-protocol super/super+shift CSI-u
# sequence. Everything else on ⌘ (⌘C/⌘V/⌘F/…) is left completely untouched.
#
# The herdr side (bindings that decode these) lives in ~/dotfiles/herdr/config.toml:
#   switch_tab=super+1..9  next_tab=super+shift+]  previous_tab=super+shift+[
#   next_workspace=super+shift+j  previous_workspace=super+shift+k
#   (switch_workspace=ctrl+1..9 — not driven from here)
#
# iTerm2 caches prefs in memory and rewrites the plist on quit, so CLI edits only
# stick while iTerm2 is NOT running. This script therefore bounces iTerm2. Your
# herdr *server* keeps every pane alive across the bounce — after iTerm2 reopens,
# run `herdr` to reattach. (Safe: we only ADD keys; nothing else is touched.)
#
# GOTCHA (found 2026-08-03): if $PLIST is a SYMLINK (e.g. dotfiles readme's iTerm2
# "Option B: symlink for syncing"), iTerm2 silently breaks it on this same relaunch —
# it does an atomic write (temp file + rename) at app startup that replaces the
# symlink with a plain file, and that plain file is NOT guaranteed to carry every
# key we just wrote (observed: SwitchTabModifier dropped entirely, only 4/13
# GlobalKeyMap entries survived, no error). So: (1) this script always de-symlinks
# $PLIST to a real file BEFORE editing, and (2) it VERIFIES the final on-disk state
# after reopen instead of trusting the mid-script write. A clean "Writing…" message
# is NOT proof the keys persisted — only the verification step at the end is.
set -euo pipefail

DOMAIN=com.googlecode.iterm2
PLIST="$HOME/Library/Preferences/${DOMAIN}.plist"
KEYMAP_RECORD="$HOME/dotfiles/iterm2/keys_config.itermkeymap"

echo "→ Quitting iTerm2 (herdr keeps your panes alive on the server)…"
osascript -e 'tell application "iTerm" to quit' >/dev/null 2>&1 || true
for _ in $(seq 1 20); do pgrep -x iTerm2 >/dev/null || break; sleep 0.3; done
pkill -x iTerm2 >/dev/null 2>&1 || true
sleep 0.5

if [ -L "$PLIST" ]; then
  echo "→ \$PLIST is a symlink (breaks on iTerm2 relaunch) — replacing with a real copy…"
  real_target="$(readlink -f "$PLIST")"
  rm "$PLIST"
  cp "$real_target" "$PLIST"
fi

echo "→ Writing the 13 ⌘ chord mappings into GlobalKeyMap…"
PLIST="$PLIST" KEYMAP_RECORD="$KEYMAP_RECORD" python3 - <<'PY'
import json, os, plistlib, pathlib

plist = pathlib.Path(os.environ["PLIST"])
d = plistlib.loads(plist.read_bytes())
gkm = d.setdefault("GlobalKeyMap", {})

ESC_SEQ = 10  # iTerm2 KEY_ACTION_ESCAPE_SEQUENCE ; Text = bytes AFTER the ESC

# ⌘1..9  → switch_tab (super+1..9)  = ESC[<49..57>;9u   (super = kitty mod 9)
# key form MUST be the Version-2 3-field "<char>-<Cmd=0x100000>-<virtual-keycode>".
# The legacy 2-field form ("0x31-0x100000") is NOT matched by modern iTerm2 for
# regular character keys, so ⌘-number fell through to the built-in "Select Tab N".
# Number-row virtual keycodes (kVK_ANSI_1..9) are non-sequential:
NUM_VKC = {"1":0x12,"2":0x13,"3":0x14,"4":0x15,"5":0x17,"6":0x16,"7":0x1a,"8":0x1c,"9":0x19}
for n, ch in enumerate("123456789", start=1):
    gkm.pop(f"0x{ord(ch):x}-0x100000", None)   # remove the non-matching legacy entry
    gkm[f"0x{ord(ch):x}-0x100000-0x{NUM_VKC[ch]:x}"] = {
        "Action": ESC_SEQ, "Version": 2, "Text": f"[{48+n};9u"}

# ⌘⇧… cyclers → super+shift (kitty mod 10). key form (Version-2 3-field):
#   "<shifted-char>-<Cmd+Shift=0x120000>-<virtual-keycode>"
# Text carries the BASE key code + mod 10 (that's what herdr's super+shift+X wants).
shifted = {
    #  chord         shifted-char  vkc     Text (herdr sees base key + super+shift)
    "cmd+shift+]": (0x7d, 0x1e, "[93;10u"),   # base ']' = 93
    "cmd+shift+[": (0x7b, 0x21, "[91;10u"),   # base '[' = 91
    "cmd+shift+j": (0x4a, 0x26, "[106;10u"),  # base 'j' = 106
    "cmd+shift+k": (0x4b, 0x28, "[107;10u"),  # base 'k' = 107
}
for _label, (char, vkc, text) in shifted.items():
    gkm[f"0x{char:x}-0x120000-0x{vkc:x}"] = {"Action": ESC_SEQ, "Version": 2, "Text": text}

# CRITICAL: iTerm2 grabs ⌘+number for "activate tab N" via a HARDCODED internal
# handler (Keys → Navigation Shortcuts → "Shortcut to activate a tab") that runs
# BEFORE GlobalKeyMap — so no key binding can override ⌘1..9 until we disable it.
# SwitchTabModifier: 3=Cmd(default) 6=Cmd+Opt 5=Opt 9=Disable. We want 9 (freed up
# for our GlobalKeyMap escapes → herdr switch_tab). We never use iTerm2 tab-by-number.
d["SwitchTabModifier"] = 9

plist.write_bytes(plistlib.dumps(d))

# Keep the tracked, importable keymap record in sync with what's now live.
record = {"Key Mappings": gkm, "Touch Bar Items": d.get("Touch Bar Items Map", {}) or {}}
pathlib.Path(os.environ["KEYMAP_RECORD"]).write_text(
    json.dumps(record, ensure_ascii=False, indent=2) + "\n"
)
print(f"   GlobalKeyMap now has {len(gkm)} entries; record → {os.environ['KEYMAP_RECORD']}")
PY

echo "→ Flushing the preferences cache so iTerm2 re-reads from disk…"
killall cfprefsd >/dev/null 2>&1 || true

echo "→ Reopening iTerm2…"
open -a iTerm
for _ in $(seq 1 20); do pgrep -x iTerm2 >/dev/null && break; sleep 0.3; done
sleep 2   # let iTerm2's own startup writes (if any) settle before we verify

echo "→ Verifying the on-disk plist actually persisted (don't trust the write above)…"
PLIST="$PLIST" python3 - <<'PY'
import os, plistlib, pathlib, sys

plist = pathlib.Path(os.environ["PLIST"])
d = plistlib.loads(plist.read_bytes())
gkm = d.get("GlobalKeyMap", {})

NUM_VKC = {"1":0x12,"2":0x13,"3":0x14,"4":0x15,"5":0x17,"6":0x16,"7":0x1a,"8":0x1c,"9":0x19}
expected = {f"0x{ord(ch):x}-0x100000-0x{NUM_VKC[ch]:x}" for ch in "123456789"}
expected |= {"0x7d-0x120000-0x1e", "0x7b-0x120000-0x21", "0x4a-0x120000-0x26", "0x4b-0x120000-0x28"}

missing = sorted(expected - set(gkm))
modifier_ok = d.get("SwitchTabModifier") == 9

ok = modifier_ok and not missing
print(f"   SwitchTabModifier: {d.get('SwitchTabModifier')!r} ({'ok' if modifier_ok else 'WRONG, expected 9'})")
print(f"   GlobalKeyMap: {len(expected) - len(missing)}/{len(expected)} expected chord entries present")
if missing:
    print(f"   MISSING: {missing}")
sys.exit(0 if ok else 1)
PY
VERIFY_STATUS=$?

if [ "$VERIFY_STATUS" -ne 0 ]; then
  cat <<'FAIL'

❌ Verification FAILED — the ⌘-chord config did not fully persist to disk.
   Re-run this script (idempotent). If it fails again, don't trust a clean
   "Writing…" message from a prior run as proof of success — only this
   verification step (or manually checking $PLIST) tells the truth.
FAIL
  exit 1
fi

cat <<'DONE'

✅ Done and verified on disk. In the fresh iTerm2 window:
   1. run:  herdr        # reattach — your panes (incl. this Claude session) are still there
   2. test: ⌘1 / ⌘2 …    # jumps herdr tabs        (⌘C / ⌘V still copy/paste as before)
            ⌘⇧] / ⌘⇧[     # next / prev herdr tab
            ⌘⇧J / ⌘⇧K     # next / prev herdr workspace
            ⌃1..9         # jump herdr workspace 1–9

   If ⌘1 still switches an iTerm2 tab: Settings → Keys → Key Bindings has a
   competing ⌘1..9 — remove those. If ⌘⇧[ / ⌘⇧] don't fire (shifted-punctuation
   is the fussy case over Kitty), tell Claude and we'll move them to ⌘⇧N / ⌘⇧P.
DONE
