#!/usr/bin/env bash
#
# tmux-iterm-boot.sh
# -----------------------------------------------------------------------------
# Runs at login (via ~/Library/LaunchAgents/com.k4lok.tmux-iterm.plist).
#
#   1. Starts the tmux server if it isn't running. Starting the server sources
#      ~/.tmux.conf, which loads tmux-continuum -> it restores all saved
#      sessions in the background (@continuum-restore 'on').
#   2. Waits for the restore to finish.
#   3. Opens ONE iTerm window with a tab per tmux session, attaching each.
#      Tab titles come from tmux itself (set-titles on / set-titles-string "#S").
#
# This replaces tmux-continuum's own boot script, which opened Terminal.app.
# To rerun by hand any time:  ~/dotfiles/scripts/tmux-iterm-boot.sh
# -----------------------------------------------------------------------------

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
TMUX_BIN="/opt/homebrew/bin/tmux"
BOOT_SESSION="__boot__"

LOG="$HOME/.tmux/iterm-boot.log"
mkdir -p "$HOME/.tmux"
# Keep only the tail of the log so it can't grow forever.
if [ -f "$LOG" ] && [ "$(wc -l < "$LOG")" -gt 500 ]; then
  tail -n 200 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
fi
exec >>"$LOG" 2>&1
echo "===== $(date '+%Y-%m-%d %H:%M:%S')  tmux-iterm-boot start ====="

# Count sessions that are NOT the throwaway bootstrap session.
real_session_count() {
  "$TMUX_BIN" list-sessions -F '#{session_name}' 2>/dev/null \
    | grep -vxc "$BOOT_SESSION"
}

# ---------------------------------------------------------------------------
# 1) Ensure the server is up and let continuum restore.
# ---------------------------------------------------------------------------
if ! "$TMUX_BIN" has-session 2>/dev/null; then
  echo "no tmux server -> starting bootstrap session (continuum will restore)"
  "$TMUX_BIN" new-session -d -s "$BOOT_SESSION" 2>/dev/null

  # 2) Wait until the restored session count is > 0 and has stayed put for a
  #    few consecutive checks (restore has settled). Cap at ~60s.
  prev=-1
  stable=0
  for i in $(seq 1 60); do
    cur="$(real_session_count)"
    echo "  t=${i}s restored=${cur}"
    if [ "${cur:-0}" -gt 0 ] && [ "$cur" = "$prev" ]; then
      stable=$((stable + 1))
      [ "$stable" -ge 3 ] && break
    else
      stable=0
    fi
    prev="$cur"
    sleep 1
  done

  # 3) Drop the bootstrap session, but only once real sessions exist (so we
  #    never kill the last session and take the whole server down).
  if [ "$(real_session_count)" -gt 0 ]; then
    "$TMUX_BIN" kill-session -t "$BOOT_SESSION" 2>/dev/null
    echo "bootstrap session removed"
  fi
else
  echo "tmux server already running -> skipping start/restore"
fi

# ---------------------------------------------------------------------------
# 4) Gather the session names (sorted for a stable tab order).
# ---------------------------------------------------------------------------
sessions=()
while IFS= read -r s; do
  [ -n "$s" ] && [ "$s" != "$BOOT_SESSION" ] && sessions+=("$s")
done < <("$TMUX_BIN" list-sessions -F '#{session_name}' 2>/dev/null | sort)

if [ "${#sessions[@]}" -eq 0 ]; then
  echo "ERROR: no tmux sessions found; nothing to open. Aborting."
  exit 1
fi
echo "opening ${#sessions[@]} iTerm tabs: ${sessions[*]}"

# ---------------------------------------------------------------------------
# 5) Build an AppleScript list literal, e.g. {"a", "b", "c"} (escaping " and \).
# ---------------------------------------------------------------------------
list="{"
for i in "${!sessions[@]}"; do
  esc=${sessions[$i]//\\/\\\\}
  esc=${esc//\"/\\\"}
  [ "$i" -gt 0 ] && list+=", "
  list+="\"$esc\""
done
list+="}"

# ---------------------------------------------------------------------------
# 6) Open iTerm: one tab per session, attach each. Titles come from tmux.
# ---------------------------------------------------------------------------
/usr/bin/osascript <<APPLESCRIPT
tell application "iTerm"
  set sessionNames to $list
  set win to (create window with default profile)
  repeat with i from 1 to count of sessionNames
    set sname to item i of sessionNames
    if i > 1 then tell win to create tab with default profile
    tell current session of win to write text "$TMUX_BIN attach -t " & quoted form of sname
  end repeat
  activate
end tell
APPLESCRIPT

echo "done."
