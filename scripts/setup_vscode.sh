#!/bin/bash
set -euo pipefail

if [[ "$OSTYPE" == "darwin"* ]]; then
    VSCODE_CONFIG_DIR="$HOME/Library/Application Support/Code/User"
else
    VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
fi
mkdir -p "$VSCODE_CONFIG_DIR"
ln -sf "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_CONFIG_DIR/settings.json"
ln -sf "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_CONFIG_DIR/keybindings.json"

echo "Installing VS Code extensions..."
while read extension; do
    code --install-extension "$extension" --force
done < "$DOTFILES_DIR/vscode/extensions.txt"
