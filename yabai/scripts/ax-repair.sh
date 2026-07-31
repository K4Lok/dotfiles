#!/usr/bin/env bash
# Repair windows that yabai can see but cannot control.
#
# Usage: ax-repair.sh [app-regex]      (default: every app except IGNORE below)
#
# Electron apps — Discord is the repeat offender — sometimes create their
# window before their accessibility tree is ready. yabai registers the window
# from the CoreGraphics list but its AX observer never attaches, leaving:
#
#     "has-ax-reference": false, "title": "", "can-move": false
#
# Such a window is tiled nowhere and ignored by every keybinding — even
# `window --toggle float` fails with "could not locate the window to act on!".
# yabai never retries the attach, so the only cure is a service restart, which
# re-scans every application from scratch.
#
# Restarting re-tiles all spaces, so we only do it when a broken window is
# actually found. Bound to a signal (Discord launch) and to a manual hotkey.

set -euo pipefail

yabai="/opt/homebrew/bin/yabai"
jq="/usr/bin/jq"

# Menubar-extra apps park a hidden, AX-less window in the window list forever.
# They are indistinguishable from a genuinely broken window (same empty title,
# is-visible=false, root-window=true), so they have to be named explicitly or
# the no-argument scan would restart yabai on every single run.
IGNORE='^(AlDente|Macs Fan Control|Tunnelblick|Surfshark|Tailscale)$'

if [ $# -gt 0 ]; then
  app="$1"; ignore='^$'      # explicit target: trust the caller
else
  app='.';  ignore="$IGNORE"
fi

# A window can legitimately look broken for a moment right after launch, so
# poll instead of judging on the first sample.
tries=8
delay=1

broken() {
  "$yabai" -m query --windows | "$jq" -r --arg app "$app" --arg ignore "$ignore" '
    map(select((.app | test($app))
               and (.app | test($ignore) | not)
               and .["has-ax-reference"] == false))
    | .[].app' | sort -u
}

for _ in $(seq "$tries"); do
  found=$(broken)
  if [ -n "$found" ]; then
    echo "ax-repair: no AX reference for: $(echo "$found" | tr '\n' ' ')— restarting yabai"
    "$yabai" --restart-service
    exit 0
  fi
  sleep "$delay"
done

echo "ax-repair: no broken windows matching /$app/"
