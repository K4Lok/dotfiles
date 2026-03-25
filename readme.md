# Dotfiles

My personal dotfiles for macOS development environment.

## Table of Contents

- [Terminal & Shell](#terminal--shell)
- [Window Management](#window-management)
- [Tools](#tools)

---

## Terminal & Shell

This setup includes a modern, aesthetically pleasing terminal environment with the **Nord theme** across all components.

### Features

- **Zsh** with Oh My Zsh framework
- **Powerlevel10k** - Fast, feature-rich prompt theme
- **zsh-autosuggestions** - Fish-like autosuggestions for Zsh
- **zsh-syntax-highlighting** - Syntax highlighting for Zsh
- **Tmux** with Nord theme for terminal multiplexing
- **iTerm2** with complete configuration including Nord color scheme, fonts, profiles, and preferences

### Installation

#### 1. Install Dependencies

```sh
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install tmux
brew install tmux

# Install iTerm2 (if not already installed)
brew install --cask iterm2
```

#### 2. Link Configuration Files

```sh
# Backup existing configs
mv ~/.zshrc ~/.zshrc.backup 2>/dev/null || true
mv ~/.p10k.zsh ~/.p10k.zsh.backup 2>/dev/null || true
mv ~/.tmux.conf ~/.tmux.conf.backup 2>/dev/null || true

# Create symlinks
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.p10k.zsh ~/.p10k.zsh
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
```

#### 3. Configure iTerm2

The iTerm2 configuration includes:
- **Nord color scheme** (embedded in the preferences)
- **Font**: JetBrains Mono Nerd Font (Regular, 12pt) for normal text, Monaco (12pt) for non-ASCII
- **Profile**: "Nord + p10k" profile with optimized settings
- **Preferences**: Window behavior, transparency, scrollback, and other customizations

**Option A: Import Preferences File (Recommended for new setup)**

1. Quit iTerm2 completely (`Cmd + Q`)
2. Backup your existing preferences:
   ```sh
   mv ~/Library/Preferences/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist.backup 2>/dev/null || true
   ```
3. Copy the preferences file:
   ```sh
   cp ~/dotfiles/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
   ```
4. Restart iTerm2 - your settings will be loaded automatically

**Option B: Use Symlink (For syncing across machines)**

1. Quit iTerm2 completely (`Cmd + Q`)
2. Backup your existing preferences:
   ```sh
   mv ~/Library/Preferences/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist.backup 2>/dev/null || true
   ```
3. Create a symlink:
   ```sh
   ln -s ~/dotfiles/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
   ```
4. Restart iTerm2

**Note**: If you don't have JetBrains Mono Nerd Font installed, you can install it via:
```sh
brew install --cask font-jetbrains-mono-nerd-font
```

#### 4. Apply Changes

```sh
# Reload zsh configuration
source ~/.zshrc

# If Powerlevel10k configuration doesn't appear automatically, run:
p10k configure
```

### Configuration Details

#### Powerlevel10k
The `.p10k.zsh` file contains instant prompt initialization and theme customization. Run `p10k configure` to personalize:
- Prompt style
- Character set
- Color scheme
- Prompt segments

#### iTerm2 Configuration
The `iterm2/com.googlecode.iterm2.plist` file contains:
- **Nord color scheme** - Complete color palette embedded in preferences
- **Font settings** - JetBrains Mono Nerd Font (12pt) for optimal readability
- **Profile configuration** - "Nord + p10k" profile with transparency, scrollback, and terminal settings
- **Window preferences** - Custom window behavior, tab settings, and appearance options
- **Keyboard shortcuts** - Custom key bindings and terminal behavior

To sync iTerm2 settings across machines, use Option B (symlink) in the installation steps above. This ensures changes are tracked in git and synced automatically.

**Exporting iTerm2 settings to this repo:**

If you've made changes in iTerm2 and want to update the config in this repo, run:
```sh
plutil -convert xml1 -o ~/dotfiles/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
```

#### Tmux Nord Theme
The `.tmux.conf` includes:
- Nord color palette integration
- Custom status bar with time and session info
- Vim-like key bindings for pane navigation
- Mouse support enabled

Key bindings:
- `Prefix + c` - Create new window
- `Prefix + n/p` - Next/previous window
- `Prefix + h/j/k/l` - Navigate panes
- `Prefix + |/-` - Split panes horizontally/vertically
- (Prefix is `Ctrl+b` by default)

---

## Window Management

This repository includes configuration for a highly efficient macOS workspace with Yabai (tiling window manager), SKHD (hotkey daemon), JankyBorders (window borders), and Karabiner-Elements (keyboard customization).

### Installation

1. Clone this repository:

   ```sh
   git clone git@github.com:K4Lok/dotfiles.git "${HOME}"/dotfiles
   ```

2. Install the required tools using Homebrew:

   ```sh
   brew install koekeishiya/formulae/yabai
   brew install koekeishiya/formulae/skhd
   brew install FelixKratz/formulae/borders
   brew install --cask karabiner-elements
   brew install jq
   ```

3. Link the configuration files:

   ```sh
   # For yabai and skhd
   rm -f "${HOME}"/.{yabai,skhd}rc
   ln -s "${HOME}"/dotfiles/yabai/yabairc "${HOME}"/.yabairc
   ln -s "${HOME}"/dotfiles/skhd/skhdrc "${HOME}"/.skhdrc

   # For Karabiner-Elements
   rm -rf "${HOME}"/.config/karabiner
   ln -s "${HOME}"/dotfiles/karabiner "${HOME}"/.config/karabiner

   # Restart Karabiner-Elements to apply symbolic link
   launchctl kickstart -k gui/`id -u`/org.pqrs.karabiner.karabiner_console_user_server
   ```

4. Load yabai scripting addition (required for advanced features):

   ```sh
   sudo yabai --load-sa
   ```

   **Important**: This command loads the yabai scripting addition, which is required for advanced features that need System Integrity Protection (SIP) to be disabled. You'll need to run this command:
   - After initial installation
   - After system updates or reboots
   - If yabai stops working properly

   Note: The yabai configuration file includes a signal handler that automatically reloads the scripting addition when the Dock restarts, but you still need to run this command manually after installation and system reboots.

5. Run the setup script to configure the 10x tool:

   ```sh
   cd "${HOME}"/dotfiles/10x
   chmod +x setup-10x
   ./setup-10x
   ```

### Features

#### Yabai
- Tiling window management with BSP layout
- Custom window padding and gaps
- Specific rules for certain applications

**Important Setup Note**: Some advanced features of yabai require disabling System Integrity Protection (SIP) and loading the scripting addition. These features include:
- Focus/move/swap/create/destroy space
- Sticky windows (make windows appear on all spaces on the display that contains the window)

After disabling SIP, you must run `sudo yabai --load-sa` to load the scripting addition. This command is included in the installation steps above and should be run after system reboots.

For more information on disabling SIP and enabling these features, please refer to the [yabai wiki on Disabling System Integrity Protection](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection).

#### SKHD
- Vim-like window focus navigation
- Quick space switching and window movement
- Window resizing and layout controls

#### JankyBorders
- Customizable window borders for active and inactive windows

#### Karabiner-Elements
- Custom key mappings for improved workflow
- Application-specific shortcuts

### Customization

Modify the configuration files in the `dotfiles` directory to suit your preferences:

- `yabai/yabairc` for Yabai settings
- `skhd/skhdrc` for keyboard shortcuts
- `karabiner/karabiner.json` for Karabiner-Elements configuration

Remember to restart services after making changes:

```sh
yabai --restart-service
```

For skhd and Karabiner-Elements, changes will apply automatically.

### Troubleshooting

#### Karabiner-Elements Service Name

If you encounter this error:
```sh
Could not find service "org.pqrs.karabiner.karabiner_console_user_server" in domain for user gui: 501
```

To find the correct Karabiner-Elements service name on your system:

1. List all Karabiner-related services:
   ```sh
   launchctl list | grep karabiner
   ```

2. Look for a service name similar to `org.pqrs.karabiner.karabiner_console_user_server` or `org.pqrs.service.agent.karabiner_console_user_server`.

3. Use the service name you find in the kickstart command:
   ```sh
   launchctl kickstart -k gui/`id -u`/[correct_service_name]
   ```

Replace `[correct_service_name]` with the actual service name you found.

---

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

---

## Notes

This setup is tailored to my personal workflow. Feel free to use it as a reference or starting point for your own productivity setup.
