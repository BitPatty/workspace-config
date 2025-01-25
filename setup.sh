#!/bin/bash

set -euo pipefail

declare -r SCRIPT_DIR=`dirname "$(realpath $0)"`
cd "$SCRIPT_DIR"

. "$SCRIPT_DIR/common.sh"

declare -r LOCAL_FONTS_DIR="$HOME/.local/share/fonts"
declare -r GIT_EMAIL="matteias.collet@protonmail.ch"
declare -r GIT_USER="Matteias Collet"
declare -r ZIG_DOWNLOAD_URL="https://ziglang.org/builds/zig-linux-x86_64-0.14.0-dev.2851+b074fb7dd.tar.xz"
declare -r ZIG_MINISIG="$SCRIPT_DIR/zig/zig-linux-x86_64-0.14.0-dev.2851+b074fb7dd.tar.xz.minisig"
declare -r ZIG_PUBLIC_KEY="RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U"

# Firewall
if confirm "Do you want to configure UFW"; then
  echo "Enabling ufw"
  assert_command ufw
  sudo ufw enable
  echo "Enabled ufw ✅"
fi

# Bash
if confirm "Do you want to configure bash"; then
  echo "Configuring bash"
  cat "$SCRIPT_DIR/bash/bashrc" > "$HOME/.bashrc"
  echo "Bash configured ✅"
fi

# SSH Key
if [[ -d "$HOME/.ssh" ]]; then
  echo "Listing SSH keys"
  ls -als "$HOME/.ssh" | grep ".pub"
else
  echo "No SSH keys found"
fi

if confirm "Do you want to generate an SSH key"; then
  echo "Creating SSH key"

  ssh-keygen -t ed25519
  echo "Configured SSH Key ✅"
fi

# Git
if confirm "Do you want to configure git"; then
  echo "Configuring git"
  assert_command git git

  git config --global user.email "$GIT_EMAIL"
  git config --global user.name "$GIT_USER"

  echo "Configured git ✅"
fi

# Fonts
DID_INSTALL_FONTS=0

if confirm "Do you want to install the fonts"; then
  assert_command fc-cache
  assert_command unzip unzip

  echo "Installing fonts"
  mkdir -p "$LOCAL_FONTS_DIR"
  unzip -n ./fonts/IosevkaFixed.zip -d "$LOCAL_FONTS_DIR"
  unzip -n ./fonts/IosevkaCurlySlab.zip -d "$LOCAL_FONTS_DIR"
  unzip -n ./fonts/IosevkaFixedCurlySlab.zip -d "$LOCAL_FONTS_DIR"

  echo "Reloading font cache"
  fc-cache -f

  DID_INSTALL_FONTS=1
  echo "Installed fonts ✅"
fi

# KDE Dolphin
if check_command dolphin && confirm "Do you want to configure dolphin"; then
  echo "Configuring dolphin"
  assert_command grep

  echo "Copying dolphinrc.."
  mkdir -p "$HOME/.config"
  cat "$SCRIPT_DIR/dolphin/dolphinrc" > "$HOME/.config/dolphinrc"

  echo "Configured dolphin ✅"
fi

# KDE Konsole
if check_command konsole && confirm "Do you want to configure konsole"; then
  echo "Configuring konsole"
  assert_command grep

  echo "Copying konsolerc.."
  mkdir -p "$HOME/.config"
  cat "$SCRIPT_DIR/konsole/konsolerc" > "$HOME/.config/konsolerc"

  echo "Copying bpty.profile.."
  mkdir -p "$HOME/.local/share/konsole"

  if [[ "$DID_INSTALL_FONTS" -eq "0" ]]; then
    grep -v '^Font=' "$SCRIPT_DIR/konsole/bpty.profile" "$HOME/.local/share/konsole/bpty.profile"
  else
    cat "$SCRIPT_DIR/konsole/bpty.profile" > "$HOME/.local/share/konsole/bpty.profile"
  fi

  echo "Copying bpty.colorscheme.."
  cat "$SCRIPT_DIR/konsole/bpty.colorscheme" > "$HOME/.local/share/konsole/bpty.colorscheme"

  echo "Configured konsole ✅"
fi

# KDE Spectacle
if check_command spectacle && confirm "Do you want to configure spectacle"; then
  echo "Configuring spectacle"

  echo "Copying spectaclerc.."
  mkdir -p "$HOME/.config"
  cat "$SCRIPT_DIR/spectacle/spectaclerc" > "$HOME/.config/spectaclerc"

  echo "Configured spectacle ✅"
fi

# VSCode
if check_command code && confirm "Do you want to configure VSCode"; then
  echo "Configuring VSCode"

  echo "Installing extensions"
  code --install-extension bitpatty.trailing-whitespace-trimmer
  code --install-extension ms-vscode-remote.remote-containers

  cat "$SCRIPT_DIR/vscode/settings.json" > "$HOME/.config/Code/User/settings.json"
  cat "$SCRIPT_DIR/vscode/keybindings.json" > "$HOME/.config/Code/User/keybindings.json"

  echo "Configured VSCode ✅"
fi

# Zig
if confirm "Do you want to configure zig"; then
  echo "Configuring zig"
  assert_command wget wget
  assert_command minisign minisign

  rm -rf "$HOME/.local/share/zig"
  rm -rf "$HOME/.local/bin/zig"

  mkdir -p "$SCRIPT_DIR/.tmp"
  mkdir -p "$HOME/.local/share/zig"
  mkdir -p "$HOME/.local/bin"

  echo "Downloading zig"
  curl -o "$SCRIPT_DIR/.tmp/zig.tar.xz" "$ZIG_DOWNLOAD_URL"
  curl -o "$SCRIPT_DIR/.tmp/zig.tar.xz.minisig" "$ZIG_DOWNLOAD_URL.minisig"

  echo "Checking signature"
  minisign -Vm "$SCRIPT_DIR/.tmp/zig.tar.xz" -P "$ZIG_PUBLIC_KEY"

  echo "Unpacking to $HOME/.local/share/zig"
  tar xvf "$SCRIPT_DIR/.tmp/zig.tar.xz" --strip-components=1 -C "$HOME/.local/share/zig"

  echo "Linking executable"
  ln -s "$HOME/.local/share/zig/zig" "$HOME/.local/bin/zig"

  echo "Configured zig ✅"
fi

echo "Setup complete"