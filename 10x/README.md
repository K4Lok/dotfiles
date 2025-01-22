# 10x Tools

A simple CLI tool to manage your macOS development environment, including window management (yabai), keyboard shortcuts (skhd), and keyboard customization (Karabiner-Elements).

## What is this?

10x Tools provides an easy way to toggle between a power-user development environment and the default macOS behavior. This is especially useful when:
- Working on shared machines
- Switching between different work environments
- Need to quickly enable/disable your custom setup

The tools managed include:
- **Yabai**: Window management
- **SKHD**: Keyboard shortcuts daemon
- **Karabiner-Elements**: Keyboard customization
- **Borders**: Window borders for yabai

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
## Requirements

- macOS
- Homebrew (will be installed if not present)

## Files

- `10x`: The main command-line tool for managing your environment
- `setup-10x`: Installation script that sets up dependencies and the CLI tool

## Configuration

The tool stores its state in `~/.config/10x/status`. Each user on the system will have their own configuration.

## Uninstallation

To uninstall:
1. Run `10x off` to disable all services
2. Remove the installed files:
```bash
rm ~/.local/bin/10x
rm -rf ~/.config/10x
```