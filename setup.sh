#!/bin/bash
set -euo pipefail

echo "Starting dotfiles setup..."

# Get the directory of the script
export DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to run a setup script
run_setup() {
    local script="$1"
    if [ -f "$DOTFILES_DIR/scripts/$script" ]; then
        echo "Running $script..."
        bash "$DOTFILES_DIR/scripts/$script"
    else
        echo "Warning: $script not found"
    fi
}

# Create necessary directories
mkdir -p ~/.config ~/.ssh

# Run individual setup scripts
run_setup "setup_homebrew.sh"
run_setup "setup_zsh.sh"
run_setup "setup_git.sh"
run_setup "setup_neovim.sh"
run_setup "setup_vim.sh"
run_setup "setup_vscode.sh"
run_setup "setup_k9s.sh"
run_setup "setup_lazygit.sh"
run_setup "setup_alacritty.sh"
run_setup "setup_tmux.sh"
run_setup "setup_starship.sh"
run_setup "setup_java.sh"
run_setup "setup_macos_preferences.sh"

echo "Dotfiles setup complete. Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
