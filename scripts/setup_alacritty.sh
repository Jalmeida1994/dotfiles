#!/bin/bash
set -euo pipefail

mkdir -p ~/.config/alacritty
ln -sf "$DOTFILES_DIR/.config/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml
