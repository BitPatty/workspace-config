#!/bin/bash

set -euo pipefail

if [ "$EUID" -eq 0 ]; then
  echo "Error: This script cannot be run as root. Please switch to a non-root user."
  exit 1
fi

# Asks the user to confirm a prompt
confirm() {
  read -p "$1? [y/N]: " response

  case "$response" in
    [yY])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Checks whether a command exists
check_command() {
  local cmd=$1
  if ! command -v "$cmd" &> /dev/null; then
    echo "Command '$cmd' not installed or not in PATH"
    return 1;
  fi

  return 0
}

# Asserts that a command exists
assert_command() {
  local cmd=$1
  local pkg=${2:-""}

  if check_command "$cmd"; then
    echo "Command '$cmd' found"
    return 0
  fi

  echo "Error: Command '$cmd' is not installed or not in PATH."

  if [[ -z "$pkg" ]]; then exit 1; fi
  if ! check_command apt ; then exit 1; fi

  if ! confirm "Do you want to install '$cmd' using apt (installs '$pkg')"; then
    echo "Aborting installation"
    exit 1
  fi

  sudo apt update && sudo apt install -y "$pkg"
  if check_command "$cmd"; then
    echo "Command '$cmd' installed successfully."
  else
    echo "Failed to install '$cmd', removing '$pkg'."
    sudo apt remove "$pkg"
    exit 1
  fi
}