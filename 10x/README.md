# 10x Tools

A simple CLI tool to manage your macOS development environment, including window management (yabai), keyboard shortcuts (skhd), and keyboard customization (Karabiner-Elements).

## What is this?

10x Tools provides an easy way to toggle between a power-user development environment and the default macOS behavior. This is especially useful when:
- Working on shared machines
- Switching between different work environments
- Need to quickly enable/disable your custom setup

The tools managed include:
- **Yabai**: A tiling window manager for macOS that automatically arranges windows in a logical layout
- **SKHD**: A hotkey daemon that allows you to define custom keyboard shortcuts for window management
- **Karabiner-Elements**: A powerful keyboard customization tool that can remap keys at a low level
- **Borders**: A lightweight tool that adds beautiful borders to windows managed by yabai

## Installation

1. Clone this repository
2. Run the setup script:
```bash
./setup-10x
```

The setup script will:
- Install required dependencies using Homebrew
- Set up the command-line tool
- Configure your PATH
- Create necessary configuration directories

## Usage

After installation, you can use the following commands:

- `10x` - Show the current status of all tools
- `10x on` - Enable all tools (yabai, skhd, karabiner, borders)
- `10x off` - Disable all tools

Example output:
```bash
=== 10x Tools Status ===
10x mode is active
Services status:
✓ yabai is running
✓ skhd is running
✓ karabiner is running
```

## What You Can Do

With 10x mode enabled, you get a powerful, keyboard-driven macOS experience:

### Window Management (via SKHD hotkeys)
- `Ctrl + Option + H/J/K/L` - Focus windows (left/down/up/right)
- `Ctrl + Option + Enter` - Swap window position
- `Ctrl + Option + Shift + H/J/K/L` - Move windows to different edges
- `Ctrl + Option + Space` - Toggle float/fullscreen
- `Ctrl + Option + 1/2/3/4` - Focus different workspaces

### Tiling (via Yabai)
- Windows automatically arrange in a tiled layout
- Custom gaps and padding for a clean look
- Specific rules for certain applications (e.g., always float calculator)

### Visual Feedback (via Borders)
- Active windows have a highlighted border
- Inactive windows have subtle borders
- Easy to see which window has focus at a glance
## Requirements

- macOS
- Homebrew (will be installed if not present)

## Files

- `10x`: The main command-line tool for managing your environment
- `setup-10x`: Installation script that sets up dependencies and the CLI tool

## Configuration

The tool stores its state in `~/.config/10x/status`. Each user on the system will have their own configuration.

### Managed Configurations

The 10x tool manages the following configuration files from this dotfiles repository:

| Tool | Config Location | Description |
|------|----------------|-------------|
| yabai | `~/dotfiles/yabai/yabairc` → `~/.yabairc` | Window placement, gaps, padding, and layout rules |
| skhd | `~/dotfiles/skhd/skhdrc` → `~/.skhdrc` | Keyboard shortcuts for window management |
| karabiner | `~/dotfiles/karabiner/` → `~/.config/karabiner/` | Key mappings and complex modifications |
| borders | Managed via yabai | Window border appearance and behavior |

### How It Works

When you run `10x on`:
1. Symlinks are created from your dotfiles to the appropriate config locations
2. All services (yabai, skhd, karabiner, borders) are started
3. Services are registered with launchd for automatic startup

When you run `10x off`:
1. All services are stopped and unregistered from launchd
2. You return to default macOS behavior

## Uninstallation

To uninstall:
1. Run `10x off` to disable all services
2. Remove the installed files:
```bash
rm ~/.local/bin/10x
rm -rf ~/.config/10x
```