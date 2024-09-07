# My macOS Productivity Setup

This repository contains my personal configuration for a highly efficient macOS workspace. It includes setup for Yabai (tiling window manager), SKHD (hotkey daemon), JankyBorders (window borders), and Karabiner-Elements (keyboard customization).

## Installation

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

   # Note: Ensure you're following the official guidelines for configuration file paths
   # See: https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/
   ```

## Features

### Yabai
- Tiling window management with BSP layout
- Custom window padding and gaps
- Specific rules for certain applications

Note: Some advanced features of yabai require disabling System Integrity Protection (SIP). These features include:
- Focus/move/swap/create/destroy space
- Sticky windows (make windows appear on all spaces on the display that contains the window)
- ...

For more information on disabling SIP and enabling these features, please refer to the [yabai wiki on Disabling System Integrity Protection](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection).

### SKHD
- Vim-like window focus navigation
- Quick space switching and window movement
- Window resizing and layout controls

### JankyBorders
- Customizable window borders for active and inactive windows

### Karabiner-Elements
- Custom key mappings for improved workflow
- Application-specific shortcuts

## Customization

Modify the configuration files in the `dotfiles` directory to suit your preferences:

- `yabai/yabairc` for Yabai settings
- `skhd/skhdrc` for keyboard shortcuts
- `karabiner/karabiner.json` for Karabiner-Elements configuration

Remember to restart services after making changes:

```sh
yabai --restart-service
```

For skhd and Karabiner-Elements, changes will apply automatically.

## Troubleshooting

### Karabiner-Elements Service Name

```sh
Could not find service "org.pqrs.karabiner.karabiner_console_user_server" in domain for user gui: 501
```

The official documentation suggests using the following command to restart Karabiner-Elements:

```sh
launchctl kickstart -k gui/`id -u`/org.pqrs.karabiner.karabiner_console_user_server
```

However, on some systems, the service name might be different. If you encounter an error like "Could not find service", you may need to identify the correct service name.

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


## Notes

This setup is tailored to my personal workflow. Feel free to use it as a reference or starting point for your own productivity setup.