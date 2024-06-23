#!/bin/bash
set -euo pipefail

mkdir -p ~/.config
ln -sf "$DOTFILES_DIR/.config/starship.toml" ~/.config/starship.toml
