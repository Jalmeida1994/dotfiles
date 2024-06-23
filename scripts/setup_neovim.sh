#!/bin/bash
set -euo pipefail

mkdir -p ~/.config/nvim/lua/user
ln -sf "$DOTFILES_DIR/.config/nvim/init.lua" ~/.config/nvim/init.lua
ln -sf "$DOTFILES_DIR/.config/nvim/lua/user/init.lua" ~/.config/nvim/lua/user/init.lua
ln -sf "$DOTFILES_DIR/.config/nvim/lua/user/packer.lua" ~/.config/nvim/lua/user/packer.lua
ln -sf "$DOTFILES_DIR/.config/nvim/lua/user/settings.lua" ~/.config/nvim/lua/user/settings.lua

echo "Installing Neovim plugins..."
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
