#!/bin/bash
set -euo pipefail

mkdir -p ~/.config/k9s
ln -sf "$DOTFILES_DIR/.config/k9s/config.yml" ~/.config/k9s/config.yml
