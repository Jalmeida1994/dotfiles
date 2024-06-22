#!/bin/bash

set -euo pipefail

echo "Setting up Git, SSH, and GPG configurations..."

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Function to update Git config
update_git_config() {
    local config_file="$1"
    local name="$2"
    local email="$3"
    local gpg_key="$4"

    # If the file is a symlink, remove it
    if [ -L "$config_file" ]; then
        rm "$config_file"
    fi

    # If the file doesn't exist, create it
    if [ ! -f "$config_file" ]; then
        touch "$config_file"
    fi

    # Update the config file
    git config -f "$config_file" user.name "$name"
    git config -f "$config_file" user.email "$email"
    git config -f "$config_file" user.signingkey "$gpg_key"
}

# Personal SSH key
read -p "Enter your personal email: " personal_email
read -p "Enter your personal name: " personal_name

# Work SSH key
read -p "Enter your work email: " work_email
read -p "Enter your work name: " work_name

# Add SSH keys to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa_personal
ssh-add ~/.ssh/id_rsa_work

# Display SSH public keys
echo "Add these SSH public keys to your GitHub accounts:"
echo "Personal SSH key:"
cat ~/.ssh/id_rsa_personal.pub
echo "Work SSH key:"
cat ~/.ssh/id_rsa_work.pub

# Generate GPG keys
echo "Generating personal GPG key..."
gpg --batch --generate-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: $personal_name
Name-Email: $personal_email
Expire-Date: 0
EOF

echo "Generating work GPG key..."
gpg --batch --generate-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: $work_name
Name-Email: $work_email
Expire-Date: 0
EOF

# Get GPG key IDs
personal_gpg=$(gpg --list-secret-keys --keyid-format LONG "$personal_email" | grep sec | awk '{print $2}' | cut -d'/' -f2)
work_gpg=$(gpg --list-secret-keys --keyid-format LONG "$work_email" | grep sec | awk '{print $2}' | cut -d'/' -f2)

# Display GPG public keys
echo "Add these GPG public keys to your GitHub accounts:"
echo "Personal GPG key:"
gpg --armor --export $personal_gpg
echo "Work GPG key:"
gpg --armor --export $work_gpg

# Update Git configs
update_git_config ~/.gitconfig-personal "$personal_name" "$personal_email" "$personal_gpg"
update_git_config ~/.gitconfig-work "$work_name" "$work_email" "$work_gpg"

# Ensure the main .gitconfig has the correct includes
git config --global --remove-section includeIf.gitdir:~/personal 2>/dev/null || true
git config --global --add includeIf.gitdir:~/personal.path ~/.gitconfig-personal

git config --global --remove-section includeIf.gitdir:~/work 2>/dev/null || true
git config --global --add includeIf.gitdir:~/work.path ~/.gitconfig-work

# Configure Git to use GPG signing
git config --global commit.gpgsign true
git config --global user.signingkey "$personal_gpg"

echo "Setup complete. Remember to add your public SSH and GPG keys to your GitHub accounts!"
echo "You may want to add 'export GPG_TTY=\$(tty)' to your .zshrc or .bash_profile to ensure GPG can prompt for passwords."