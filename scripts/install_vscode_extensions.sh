#!/bin/bash

set -euo pipefail

while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip empty lines and comments
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "$line" ]] && continue

  extension="$line"
  if ! code --list-extensions | grep -q "^${extension}$"; then
    echo "Installing $extension..."
    code --install-extension "$extension" --force
  else
    echo "$extension is already installed."
  fi
done < ./vscode/extensions.txt

echo "VS Code extensions installation complete."