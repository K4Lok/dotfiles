# Dotfiles

My personal dotfiles for macOS development environment.

## Tools

### 10x

A CLI tool to manage and toggle all the development tools in this repository. It provides an easy way to switch between power-user setup and default macOS behavior.

```bash
10x        # Show status
10x on     # Enable all tools
10x off    # Disable all tools
```

See [10x/README.md](10x/README.md) for detailed setup and usage.

### Configurations

- **yabai**: Window management
- **skhd**: Keyboard shortcuts daemon
- **karabiner**: Keyboard customization

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

1. Clone this repository:
```bash
git clone https://github.com/yourusername/10x-tools.git
cd 10x-tools
```

2. Set up required permissions:
```bash
# Make scripts executable
chmod +x setup-10x
chmod +x 10x

# Set up yabai scripting addition
# Note: This requires SIP to be partially disabled
sudo yabai --install-sa
sudo yabai --load-sa

# Grant accessibility permissions
echo "Please grant accessibility permissions for:"
echo "- Yabai"
echo "- SKHD"
echo "- Karabiner-Elements"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
```

3. Run the setup script:
```bash
./setup-10x
```

4. After installation, restart your terminal or run:
```bash
source ~/.zshrc
```

### System Integrity Protection (SIP)

Yabai requires SIP to be partially disabled for full functionality. To configure this:

1. Restart your Mac in Recovery Mode (hold Command + R during startup)
2. Open Terminal from Utilities menu
3. Run:
```bash
csrutil enable --without debug --without fs
```
4. Restart your Mac

### Accessibility Permissions

The tools require accessibility permissions to function properly. You'll need to enable them in:
- System Settings > Privacy & Security > Accessibility

Add permissions for:
- Yabai
- SKHD
- Karabiner-Elements

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
- Partially disabled SIP for full yabai functionality

## Files

- `10x`: The main command-line tool for managing your environment
- `setup-10x`: Installation script that sets up dependencies and the CLI tool

## Configuration

The tool stores its state in `~/.config/10x/status`. Each user on the system will have their own configuration.

## Troubleshooting

If you encounter permission issues:

1. Check service status:
```bash
yabai --check-sa
skhd --version
```

2. Verify permissions:
```bash
ls -la ~/.local/bin/10x
ls -la /usr/local/bin/yabai
```

3. Common fixes:
```bash
# Reset yabai scripting addition
sudo yabai --uninstall-sa
sudo yabai --install-sa

# Reset permissions
chmod +x ~/.local/bin/10x
```

## Uninstallation

To uninstall:
1. Run `10x off` to disable all services
2. Remove the installed files:
```bash
rm ~/.local/bin/10x
rm -rf ~/.config/10x
```

## Contributing

Feel free to open issues or submit pull requests if you have suggestions for improvements!

## License

MIT License