#!/usr/bin/env bash
# Focus a display, then land focus on a *real* window — never the invisible
# Typeless "Status" overlay or other non-standard windows.
#
# Usage: focus-display.sh [next|prev|first|last|<index>]   (default: next)
#
# next/prev do NOT wrap on their own (yabai errors past the last display), so
# we resolve the target display index up front and wrap manually. Resolving the
# index explicitly also avoids a race: `display --focus` settles asynchronously,
# so querying the "focused display" right after can still return the old one and
# bounce focus back.

set -euo pipefail

yabai="/opt/homebrew/bin/yabai"
jq="/usr/bin/jq"

dir="${1:-next}"

total=$("$yabai" -m query --displays | "$jq" length)
cur=$("$yabai" -m query --displays --display | "$jq" .index)

case "$dir" in
  next)  target=$(( cur % total + 1 )) ;;            # wraps last -> first
  prev)  target=$(( (cur - 2 + total) % total + 1 )) ;;  # wraps first -> last
  first) target=1 ;;
  last)  target=$total ;;
  *)     target=$dir ;;                              # explicit index
esac

"$yabai" -m display --focus "$target"

# Pick a focusable window on the target display:
#   - visible
#   - a standard window (skips AXDialog overlays like Typeless "Status")
#   - not Typeless
# Prefer the one that already has focus there, otherwise the first candidate.
win=$("$yabai" -m query --windows --display "$target" | "$jq" -r '
  map(select(.["is-visible"] == true
             and .subrole == "AXStandardWindow"
             and (.app | test("Typeless") | not)))
  | (map(select(.["has-focus"] == true))[0].id) // (.[0].id) // empty')

[ -n "$win" ] && "$yabai" -m window --focus "$win"
