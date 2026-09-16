#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0" | realpath)"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"

link_directory() {
  if [[ ! -d "$1" ]]; then
    echo "Source Directory \"$1\" does not exist."
    return 1
  fi

  if [[ ! -e "$2" && ! -L "$2" ]]; then
    ln -s "$1" "$2"
  fi
}

link_file() {
  if [[ ! -f "$1" ]]; then
    echo "Source file \"$1\" does not exist."
    return 1
  fi

  if [[ ! -e "$2" && ! -L "$2" ]]; then
    ln -s "$1" "$2"
  fi
}

# zsh
link_file "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"

# neovim
link_directory "$SCRIPT_DIR/nvim/" "$XDG_CONFIG_HOME/nvim"

# ghostty
link_directory "$SCRIPT_DIR/ghostty/" "$HOME/Library/Application Support/com.mitchellh.ghostty"
