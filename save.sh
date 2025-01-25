#!/bin/bash

set -euo pipefail

declare -r SCRIPT_DIR=`dirname "$(realpath $0)"`
cd "$SCRIPT_DIR"

. "$SCRIPT_DIR/common.sh"

# Bash
if confirm "Back up bash configuration"; then
  echo "Backing up bash configuration"
  assert_command grep

  mkdir -p "$SCRIPT_DIR/bash"

  if [[ -f "$HOME/.bashrc" ]]; then
    echo "Copying bashrc.."
    cat "$HOME/.bashrc" > "$SCRIPT_DIR/bash/bashrc"
  fi

  echo "Backed up bash configuration ✅"
fi

# KDE Dolphin
if check_command dolphin && confirm "Back up dolphin configuration"; then
  echo "Backing up dolphin configuration"

  mkdir -p "$SCRIPT_DIR/dolphin"

  if [[ -f "$HOME/.config/dolphinrc" ]]; then
    echo "Copying dolphinrc.."
    cat "$HOME/.config/dolphinrc" > "$SCRIPT_DIR/dolphin/dolphinrc"
  fi

  echo "Backed up dolphin configuration ✅"
fi

# KDE Konsole
if check_command konsole && confirm "Back up konsole configuration"; then
  echo "Backing up konsole configuration"
  assert_command grep

  mkdir -p "$SCRIPT_DIR/konsole"

  if [[ -f "$HOME/.config/konsolerc" ]]; then
    echo "Copying konsolerc.."
    cat "$HOME/.config/konsolerc" > "$SCRIPT_DIR/konsole/konsolerc"
  fi

  if [[ -f "$HOME/.local/share/konsole/bpty.profile" ]]; then
    echo "Copying bpty.profile.."
    cat "$HOME/.local/share/konsole/bpty.profile" > "$SCRIPT_DIR/konsole/bpty.profile"
  fi

  echo "Backed up konsole configuration ✅"
fi

# KDE Spectacle
if check_command spectacle && confirm "Back up spectacle configuration"; then
  echo "Backing up spectacle configuration"
  assert_command grep

  mkdir -p "$SCRIPT_DIR/spectacle"

  if [[ -f "$HOME/.config/spectaclerc" ]]; then
    echo "Copying spectaclerc.."
    grep -v '^lastSaveLocation=' "$HOME/.config/spectaclerc" > "$SCRIPT_DIR/spectacle/spectaclerc"
  fi

  echo "Backed up spectacle configuration ✅"
fi

# VSCode
if check_command code && confirm "Back up VSCode configuration"; then
  echo "Backing up VSCode configuration"
  assert_command grep

  mkdir -p "$SCRIPT_DIR/vscode"

  if [[ -f "$HOME/.config/Code/User/settings.json" ]]; then
    echo "Copying settings.json.."
    cat "$HOME/.config/Code/User/settings.json" > "$SCRIPT_DIR/vscode/settings.json"
  fi

  if [[ -f "$HOME/.config/Code/User/keybindings.json" ]]; then
    echo "Copying keybindings.json.."
    cat "$HOME/.config/Code/User/keybindings.json" > "$SCRIPT_DIR/vscode/keybindings.json"
  fi

  echo "Backed up VSCode configuration ✅"
fi

echo "Backup complete"