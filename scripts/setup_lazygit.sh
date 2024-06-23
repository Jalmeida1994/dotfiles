#!/bin/bash
set -euo pipefail

mkdir -p ~/.config/lazygit
ln -sf "$DOTFILES_DIR/.config/lazygit/config.yml" ~/.config/lazygit/config.yml
