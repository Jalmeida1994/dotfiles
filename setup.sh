#!/bin/bash

set -euo pipefail

echo "Starting dotfiles setup..."

# Get the directory of the script
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create necessary directories
mkdir -p ~/.config/{alacritty,nvim,starship}
mkdir -p ~/.config/nvim/lua/user
mkdir -p ~/.ssh

# Symlink configuration files
ln -sf "$DOTFILES_DIR/.config/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml
ln -sf "$DOTFILES_DIR/.config/nvim/init.lua" ~/.config/nvim/init.lua
ln -sf "$DOTFILES_DIR/.config/nvim/lua/user/init.lua" ~/.config/nvim/lua/user/init.lua
ln -sf "$DOTFILES_DIR/.config/nvim/lua/user/packer.lua" ~/.config/nvim/lua/user/packer.lua
ln -sf "$DOTFILES_DIR/.config/nvim/lua/user/settings.lua" ~/.config/nvim/lua/user/settings.lua
ln -sf "$DOTFILES_DIR/.config/starship.toml" ~/.config/starship.toml
ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/.vimrc" ~/.vimrc
ln -sf "$DOTFILES_DIR/.tmux.conf" ~/.tmux.conf
ln -sf "$DOTFILES_DIR/.gitignore_global" ~/.gitignore_global

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for the current session
    if [[ $(uname -m) == 'arm64' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    # Add Homebrew to PATH permanently
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
    fi
else
    echo "Homebrew already installed. Updating..."
    brew update
fi

# Install Homebrew packages
echo "Installing Homebrew packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# Set default shell to zsh if not already set
if [[ $SHELL != */zsh ]]; then
    echo "Setting Zsh as default shell..."
    chsh -s $(which zsh)
fi

# Install fzf key bindings and fuzzy completion
echo "Setting up fzf..."
$(brew --prefix)/opt/fzf/install --all

echo "Installing Java versions..."
./scripts/install_java.sh

# Set macOS preferences
echo "Setting macOS preferences..."
./scripts/macos_preferences.sh

# Install VS Code extensions
echo "Installing VS Code extensions..."
./scripts/install_vscode_extensions.sh

# VS Code settings
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    VSCODE_CONFIG_DIR="$HOME/Library/Application Support/Code/User"
else
    # Linux
    VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
fi
mkdir -p "$VSCODE_CONFIG_DIR"
ln -sf "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_CONFIG_DIR/settings.json"
ln -sf "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_CONFIG_DIR/keybindings.json"

# Install Neovim plugins
echo "Installing Neovim plugins..."
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# Optional: SSH and GPG setup
read -p "Do you want to set up SSH and GPG keys? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Setting up SSH and GPG keys..."
    "$DOTFILES_DIR/scripts/git_setup.sh"
fi

# Set global gitignore
echo "Setting up global gitignore..."
git config --global core.excludesfile ~/.gitignore_global

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Dotfiles setup complete. Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
