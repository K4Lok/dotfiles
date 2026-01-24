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
- **iTerm2** with Nord color scheme

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

1. Open iTerm2 preferences (`Cmd + ,`)
2. Navigate to **Profiles** → **Colors**
3. Click **Color Presets...** → **Import...**
4. Import the Nord theme from: `iterm2/Nord.itermcolors`
5. Select **Nord** from the presets

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

4. Run the setup script to configure the 10x tool:

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

Note: Some advanced features of yabai require disabling System Integrity Protection (SIP). These features include:
- Focus/move/swap/create/destroy space
- Sticky windows (make windows appear on all spaces on the display that contains the window)

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
