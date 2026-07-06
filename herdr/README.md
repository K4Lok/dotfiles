# herdr

[herdr](https://herdr.dev) — an agent multiplexer that lives in the terminal (workspaces →
tabs → panes, with agent-focus actions and git-worktree helpers). Used here as a **tmux
replacement**, chosen mainly for its **moshi** (mosh-over-Tailscale) support, which makes AI
coding from mobile genuinely usable.

- **Config:** [`config.toml`](./config.toml) → symlinked to `~/.config/herdr/config.toml`
  (ported from [`../.tmux.conf`](../.tmux.conf))
- **⌘-chord forwarding:** [`../scripts/iterm-herdr-cmd-keys.sh`](../scripts/iterm-herdr-cmd-keys.sh)
- **Tracked iTerm2 keymap:** [`../iterm2/keys_config.itermkeymap`](../iterm2/keys_config.itermkeymap)

Full write-ups live in the Obsidian vault (`Knowledge Base/Development/Terminal/Herdr — …`):
setup + tmux→herdr map, the ⌘-chord forwarding mechanism, paste/theme fixes, and a cheat sheet.

---

## Install (fresh machine)

```sh
# 1. Binary (Homebrew core formula — stable 0.7.1)
brew install herdr

# 2. Symlink the config
mkdir -p ~/.config/herdr
ln -sfn ~/dotfiles/herdr/config.toml ~/.config/herdr/config.toml

# 3. Agent integrations — needed for [session] resume_agents_on_restore to work.
#    Each writes a state hook into the agent's own config dir. Install the ones you use;
#    a skip just means that agent isn't set up on this machine.
herdr integration install claude
herdr integration install codex
herdr integration install opencode      # needs ~/.config/opencode to exist first
herdr integration status                # each installed agent should read "current"

# 4. Launch (starts the persistent server + attaches)
herdr

# 5. ⌘-chord tab/workspace nav — see "iTerm2 setup" below (bounces iTerm2)
bash ~/dotfiles/scripts/iterm-herdr-cmd-keys.sh
```

Edit the config any time, then apply live without restarting:

```sh
herdr server reload-config     # clean == {"diagnostics":[],"status":"applied"}
```

`herdr config reset-keys` backs up `config.toml` and removes custom keybindings.
Channels: `herdr channel set preview|stable` then `herdr update`.

---

## iTerm2 setup (three things herdr can't do itself)

herdr runs *inside* iTerm2, so three iTerm2-side settings complete the keymap.

### A. ⌘ chords → herdr (tab / workspace nav)

`⌘1..9`, `⌘⇧[`/`⌘⇧]`, `⌘⇧J`/`⌘⇧K` are forwarded into herdr as Kitty CSI-u `super` sequences
by 13 per-chord iTerm2 GlobalKeyMap "Send Escape Sequence" entries, plus `SwitchTabModifier=9`
so iTerm2 stops eating ⌘-number for its own tabs. The script writes those into the live plist
and syncs the tracked record `iterm2/keys_config.itermkeymap`:

```sh
bash ~/dotfiles/scripts/iterm-herdr-cmd-keys.sh
```

> ⚠️ The script **quits and relaunches iTerm2** (iTerm2 only persists external plist writes
> while it is not running). The herdr **server keeps every pane alive** across the bounce —
> reattach with `herdr` after it reopens. `⌘C`/`⌘V`/`⌘F` are left untouched; only the 13 nav
> chords are forwarded. Re-run anytime; idempotent.

Isolation test: if `⌃1..9` jumps workspaces but `⌘1..9` does nothing, the missing piece is
always the iTerm2 side (`⌃` is native herdr, `⌘` needs this script).

### B. Option key → Esc+ (unlocks the agent layer)

`focus_agent` / `next_agent` / `previous_agent` use `alt` chords, which are **silently dead**
until iTerm2 passes Option through instead of composing accents (é/∆/ø):

**Settings (⌘,) → Profiles → Keys → General → Left & Right Option Key = `Esc+`.**

### C. Bracketed paste (stop multi-line pastes from auto-submitting)

Multi-line pastes into an agent pane break mid-paragraph because iTerm2 disables bracketed
paste on every shell dir-change:

**Settings (⌘,) → Advanced → search `bracketed` → "When the current session's host changes,
turn off bracketed paste mode" → `No`.** Then full-quit iTerm2 (⌘Q) and reopen.

---

## Keybindings (what differs from herdr defaults)

Prefix = `ctrl+b` (tmux-style). Everything not listed is a herdr default.

| Action | Bound to | vs. herdr default |
|---|---|---|
| `focus_pane_left/down/up/right` | `ctrl+h/j/k/l` | default `prefix+h/j/k/l` |
| `split_vertical` (side-by-side) | `prefix+\|` | default `prefix+v` (restores tmux) |
| `split_horizontal` (stacked) | `prefix+minus` | default |
| `switch_tab` (tab 1–9) | `⌘1..9` (`super+1..9`) | default `prefix+1..9` — via iTerm2 forward |
| `next_tab` / `previous_tab` | `⌘⇧]` / `⌘⇧[` | default `prefix+n`/`p` — via iTerm2 forward |
| `switch_workspace` (ws 1–9) | `⌃1..9` (`ctrl+1..9`) | default `prefix+shift+1..9` — **native** |
| `next_workspace`/`previous_workspace` | `⌘⇧J` / `⌘⇧K` | unset by default — via iTerm2 forward |
| `focus_agent` (agent 1–9) | `prefix+alt+1..9` | unset by default (needs Option=Esc+) |
| `next_agent`/`previous_agent` | `ctrl+alt+j` / `ctrl+alt+k` | unset by default (needs Option=Esc+) |

Splits are named by **divider orientation** (tmux `split -h` side-by-side == herdr
`split_vertical`).

**Session restore** (`[session] resume_agents_on_restore` + `[experimental] pane_history`):
on a server restart, agent panes reconnect to their native conversation sessions and prior
scrollback is restored — the tmux-resurrect/continuum equivalent. Requires the agent
integrations from step 3 (silent no-op without them).

**Theme:** base `nord` with a solid `panel_bg` (#2e3440) so a translucent iTerm2 window
doesn't wash out the sidebar; only muted tokens are lifted for legibility. `[theme.custom]`
accepts exactly 16 tokens and **silently drops unknown keys** — a clean `reload-config` does
*not* validate names.

---

## Gotchas

- `ctrl+h/j/k/l` become **global** chords (no vim-tmux-navigator passthrough) — if `ctrl+j/k`
  collide with vim, switch that block to `ctrl+alt+h/j/k/l`.
- iTerm2 rewrites its plist **on quit**, so plist edits only persist while it is not running —
  that's why the ⌘-chord script bounces it.
- `ctrl+alt+j/k` collide with Enter (0x0A/0x0D) in legacy encoding; they work cleanly only via
  the Kitty protocol iTerm2 3.6+ negotiates. If cycling gets flaky, that's why.
- `⌘⇧[`/`⌘⇧]` (shifted punctuation over Kitty) is the least-certain chord — if it won't fire,
  fall back to `prefix+n`/`p` or move to `⌘⇧N`/`⌘⇧P`.
