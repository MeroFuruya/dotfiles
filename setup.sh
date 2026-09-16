#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0" | realpath)"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"

# zsh
ZSH_CONFIG_DEST="$HOME/.zshrc"
if [[ ! -f "$ZSH_CONFIG_DEST" ]]; then 
  ln "$SCRIPT_DIR/zsh/.zshrc" "$ZSH_CONFIG_DEST"
fi

# neovim
NEOVIM_CONFIG_DEST="$XDG_CONFIG_HOME/nvim"
if [[ ! -e "$NEOVIM_CONFIG_DEST" && ! -L "$NEOVIM_CONFIG_DEST" ]]; then
  ln -s "$SCRIPT_DIR/nvim/" "$NEOVIM_CONFIG_DEST"
fi

# ghostty
GHOSTTY_CONFIG_DEST="$HOME/Library/Application Support/com.mitchellh.ghostty"
if [[ ! -d "$GHOSTTY_CONFIG_DEST" ]]; then 
  ln -s "$SCRIPT_DIR/ghostty/" "$GHOSTTY_CONFIG_DEST"
fi
