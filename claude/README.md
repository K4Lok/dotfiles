# Claude Code

Status line config for [Claude Code](https://claude.ai/code), powered by
[`ccstatusline`](https://github.com/sirmalloc/ccstatusline) (run via `bunx`/`npx`,
no install needed). The layout adapts to the terminal width, so it stays readable
on a phone over mosh as well as on a desktop.

## Files

- `ccstatusline.sh` — responsive launcher. Probes the terminal width and hands
  ccstatusline the config that fits. This is what `statusLine.command` points at.
- `ccstatusline.json` — the wide (desktop) layout. Symlinked to
  `~/.config/ccstatusline/settings.json`, so the interactive editor edits this one.
- `ccstatusline.medium.json` — the mid layout used from 60–99 columns. Same widgets
  as the wide one, minus the weekly progress bar.
- `ccstatusline.narrow.json` — the compact layout used below 60 columns
  (phone over mosh). Fits in ~24 columns.
- `settings.statusline.json` — the `statusLine` block to merge into
  `~/.claude/settings.json`. Not symlinked directly because `~/.claude/settings.json`
  also holds machine-specific state (enabled plugins, MCP marketplaces).

## Layouts

**Wide (≥100 cols)** — `ccstatusline.json`

```
Model: Opus 5 | Ctx: 102.3k | ⎇ main | (+58,-3)
2hr 34m | Session: 27.0% | Weekly: [██████████░░░░░░] 62.0% | Weekly Reset: 1d 9hr 34m
```

**Medium (60–99 cols)** — `ccstatusline.medium.json`

```
Model: Opus 5 | Ctx: 102.3k | ⎇ main | (+58,-3)
2h34m | Session: 27.0% | Weekly: 62.0% | 1d9h34m
```

**Narrow (<60 cols)** — `ccstatusline.narrow.json`

```
Opus 5 | 0.0% | main
2h34m | S27.0% | W62.0%
```

## Why the launcher exists

ccstatusline renders one fixed widget set, then hard-truncates the result to
`flexMode`'s effective width. Two things went wrong on a phone-sized terminal:

- `flexMode: "full-minus-40"` reserves 40 columns unconditionally. At 61 detected
  columns that leaves **21** usable, so the line came out as `Model: Opus 5 | Ct...`
  — clipped far shorter than the space actually available.
- Below 40 columns the reserve goes negative, ccstatusline skips truncation
  entirely and emits an 86-char line for Claude Code to clip.

Fix: `flexMode` is now `full-until-compact` (reserves 6, and only drops to 40 when
context actually approaches auto-compact), and `ccstatusline.sh` swaps in a layout
that fits when the terminal is narrow.

### Why width, and not "am I on mosh?"

Tempting, but wrong signal — and it doesn't work here anyway. Under a multiplexer
the server is a daemon reparented to init, so walking up from Claude Code lands on
the machine's local tty and never reaches `mosh-server`:

```
mosh-server (tty ??) -> mux client (tty B)          <- phone attaches over here
mux server (tty A) -> shell (tty C) -> claude (C)   <- but Claude Code lives over here
```

Those are separate branches of the process tree. Width, on the other hand, is
exactly right: the pane's pty gets resized when the phone attaches, so `stty size`
on it already reports the real viewport — and it degrades sensibly for a narrow
split pane on the desktop too, which a mosh check would miss.

## Install on a new machine

Nothing here is host-specific — the launcher finds its configs relative to itself,
and `statusLine.command` goes through `$HOME`. Clone anywhere under `~/dotfiles`
and the three steps below are the whole setup. macOS and Linux both work.

```sh
# 1. Prereq: bun preferred, but the launcher falls back to npx, then to a
#    globally installed ccstatusline. Any one of the three is enough.
brew install bun     # or: apt install nodejs npm  /  npm i -g ccstatusline

# 2. Symlink the wide ccstatusline config
mkdir -p ~/.config/ccstatusline
ln -sf ~/dotfiles/claude/ccstatusline.json ~/.config/ccstatusline/settings.json

# 3. Wire it into Claude Code: merge the statusLine block from
#    settings.statusline.json into ~/.claude/settings.json
#    (paste it in by hand, or with jq if the file already exists:)
jq -s '.[0] * .[1]' ~/.claude/settings.json ~/dotfiles/claude/settings.statusline.json \
  > /tmp/cc.json && mv /tmp/cc.json ~/.claude/settings.json
```

Restart Claude Code and the two-line status bar appears.

## Editing later

Run `bunx ccstatusline@latest` for the interactive config editor — it writes to
`~/.config/ccstatusline/settings.json`, which is the symlink, so changes to the
**wide** layout land in this repo automatically.

For the medium and narrow layouts, point the editor at them explicitly:

```sh
bunx ccstatusline@latest --config ~/dotfiles/claude/ccstatusline.medium.json
bunx ccstatusline@latest --config ~/dotfiles/claude/ccstatusline.narrow.json
```

To preview any layout at a given width without resizing anything:

```sh
echo '{"model":{"display_name":"Opus 5"},"workspace":{"current_dir":"'"$PWD"'"}}' \
  | CCSTATUSLINE_WIDTH=40 ~/dotfiles/claude/ccstatusline.sh
```

The switchover points live in `MEDIUM_BELOW` / `NARROW_BELOW` at the top of
`ccstatusline.sh`. Nothing in these files hardcodes a home directory: the launcher
resolves its configs relative to its own location, and `statusLine.command` uses
`$HOME` (Claude Code runs it through a shell).
