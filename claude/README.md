# Claude Code

Status line config for [Claude Code](https://claude.ai/code), powered by
[`ccstatusline`](https://github.com/sirmalloc/ccstatusline) (run via `bunx`, no install needed).

## Files

- `ccstatusline.json` — the actual status bar layout/widgets (the part worth syncing).
  Symlinked to `~/.config/ccstatusline/settings.json`.
- `settings.statusline.json` — the 5-line `statusLine` block to merge into
  `~/.claude/settings.json`. Not symlinked directly because `~/.claude/settings.json`
  also holds machine-specific state (enabled plugins, MCP marketplaces).

## Current layout

- **Line 1:** model · context-length · git-branch · git-changes
- **Line 2:** reset-timer · session-usage · weekly-usage (progress bar) · weekly-reset-timer

## Install (e.g. on the Mac mini)

```sh
# 1. Prereq: bun (ccstatusline runs via bunx)
brew install bun

# 2. Symlink the ccstatusline config
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
`~/.config/ccstatusline/settings.json`, which is the symlink, so changes land in
this repo automatically. Commit them.
