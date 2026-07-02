# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="$HOME/.local/bin:$PATH"

# Rust / Cargo (rustup)
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias pn="pnpm"
alias vim='/opt/homebrew/bin/vim'

bindkey -e
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
alias c='cursor'
alias cc='claude'

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

eval "$(mise activate zsh)"
export PATH=$PATH:$HOME/.maestro/bin

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

export LANG=zh_TW.UTF-8

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"



# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="false"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$HOME/.orbstack/bin:$PATH"
export PATH="$PATH:$HOME/.pub-cache/bin"

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=251,bold,underline'
export ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=203'

alias cpbn='git branch --show-current | pbcopy'

export DFX_MOC_PATH=moc-wrapper

# ── Work VPN (openvpn CLI) ──────────────────────────────────────────
# Config: ~/.config/openvpn/work.ovpn (cert-only auth; never committed).
# Usage: vpn-up → ssh -fN <db-tunnel> → vpn-down   (host alias lives in ~/.ssh/config)
export VPN_CFG="$HOME/.config/openvpn/work.ovpn"
export VPN_PID="$HOME/.config/openvpn/work.pid"
export VPN_LOG="$HOME/.config/openvpn/work.log"
# Bypass helper lives in this dotfiles repo, so every cloned device has it
# with no extra symlink step.
export VPN_TS_BYPASS="$HOME/dotfiles/openvpn/tailscale-bypass.sh"

vpn-up() {
  if [ -f "$VPN_PID" ] && sudo kill -0 "$(cat "$VPN_PID")" 2>/dev/null; then
    echo "VPN already up (pid $(cat "$VPN_PID"))"; return 0
  fi
  # Self-heal for a device set up before the config was renamed: if the expected
  # config is absent but exactly one other *.ovpn sits alongside it, adopt that
  # one. Discovered at runtime so no old/identifying filename lives in this repo.
  if [ ! -f "$VPN_CFG" ]; then
    local _vdir _legacy _n
    _vdir=$(dirname "$VPN_CFG")
    _legacy=$(find "$_vdir" -maxdepth 1 -type f -name '*.ovpn' ! -name "$(basename "$VPN_CFG")" 2>/dev/null)
    _n=$(printf '%s' "$_legacy" | grep -c .)
    if [ "$_n" = "1" ]; then
      echo "Adopting existing OpenVPN config → $(basename "$VPN_CFG")"
      mv "$_legacy" "$VPN_CFG" || { echo "⚠️  could not rename config"; return 1; }
    elif [ "$_n" -gt 1 ]; then
      echo "⚠️  $VPN_CFG missing and multiple *.ovpn present — rename the right one to $(basename "$VPN_CFG") manually"; return 1
    else
      echo "⚠️  VPN config not found: $VPN_CFG — install the OpenVPN profile there"; return 1
    fi
  fi
  # Capture the real router BEFORE the full tunnel takes over, so Tailscale's
  # DERP/control traffic can be pinned back to it (see tailscale-bypass.sh).
  local phys_gw
  phys_gw=$(route -n get default 2>/dev/null | awk '/gateway/{print $2; exit}')
  echo "Starting VPN (sudo)…"
  sudo openvpn --config "$VPN_CFG" --daemon --writepid "$VPN_PID" --log "$VPN_LOG"
  for i in {1..15}; do
    if grep -q "Initialization Sequence Completed" "$VPN_LOG" 2>/dev/null; then
      echo "✅ VPN up"
      PHYS_GW="$phys_gw" sh "$VPN_TS_BYPASS" add || echo "⚠️  tailscale-bypass failed — Tailscale may be down"
      # Re-pin a few seconds later: some /32 DERP routes can fail to land on the
      # first pass while the tunnel's own 0/1+128.0/1 routes are still settling,
      # leaving only a subset of a region's relay nodes pinned (root cause of the
      # 2026-07-02 breakage: only 1 of 3 hkg nodes pinned → Tailscale relay/mosh
      # broke when it used an unpinned node). `add` re-pulls the live DERP map and
      # is idempotent (route add||change||true), so this backfills the stragglers.
      # sudo is still cached from the openvpn start above, so no prompt.
      ( sleep 6; PHYS_GW="$phys_gw" sh "$VPN_TS_BYPASS" add >/dev/null 2>&1 ) &
      vpn-status; return 0
    fi
    sleep 1
  done
  echo "⚠️  VPN didn't confirm in 15s — tail $VPN_LOG"; return 1
}

vpn-down() {
  sh "$VPN_TS_BYPASS" del 2>/dev/null || true
  if [ -f "$VPN_PID" ]; then
    sudo kill "$(cat "$VPN_PID")" 2>/dev/null && echo "VPN stopped"
    sudo rm -f "$VPN_PID"
  else
    sudo pkill -f "openvpn --config $VPN_CFG" && echo "VPN stopped (by name)" || echo "VPN was not running"
  fi
}

# Show whether the tunnel process is alive, plus current public IP + geo
# (so you can confirm traffic is actually egressing via the VPN).
vpn-status() {
  if [ -f "$VPN_PID" ] && sudo kill -0 "$(cat "$VPN_PID")" 2>/dev/null; then
    echo "VPN process: UP (pid $(cat "$VPN_PID"))"
  else
    echo "VPN process: DOWN"
  fi
  echo "Public IP / location:"
  local info
  info=$(curl -fsS --max-time 8 ipinfo.io/json 2>/dev/null)
  if [ -n "$info" ]; then
    echo "$info" | jq -r '"  ip:      \(.ip)\n  location: \(.city), \(.region), \(.country)\n  org:     \(.org)"'
  else
    echo "  (could not reach ipinfo.io — check connectivity)"
  fi
}

