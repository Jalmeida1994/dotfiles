#!/bin/bash
set -euo pipefail

ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install fzf key bindings and fuzzy completion
echo "Setting up fzf..."
$(brew --prefix)/opt/fzf/install --all
