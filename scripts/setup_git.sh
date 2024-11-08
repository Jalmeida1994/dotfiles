#!/bin/bash

set -euo pipefail

echo "Setting up Git, SSH, and GPG configurations..."

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Create a global .gitignore file
ln -sf "$DOTFILES_DIR/.gitignore_global" ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

# Function to ask yes/no question
ask_yes_no() {
    while true; do
        read -p "$1 (y/n): " -n 1 -r
        echo
        case $REPLY in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

# Function to update SSH config
update_ssh_config() {
    local host="$1"
    local hostname="$2"
    local identity_file="$3"

    # Check if the host already exists in the config
    if grep -q "Host $host" "$HOME/.ssh/config"; then
        echo "Host $host already exists in SSH config. Skipping..."
    else
        # Append to SSH config
        cat <<EOF >> "$HOME/.ssh/config"

Host $host
    HostName $hostname
    User git
    IdentityFile $identity_file
EOF
        echo "Added $host to SSH config."
    fi
}

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

# Function to create SSH key if it doesn't exist
create_ssh_key() {
    local email="$1"
    local key_file="$2"
    if [ ! -f "$key_file" ]; then
        ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
    else
        echo "SSH key $key_file already exists. Skipping creation."
    fi
}

# SSH setup
if ask_yes_no "Do you want to set up SSH keys?"; then
    # Ensure SSH directory exists and has correct permissions
    if [ ! -d "$HOME/.ssh" ]; then
        echo "Creating .ssh directory..."
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
    fi

    # Check if ~/.ssh/config is a symlink and remove it if it is
    if [ -L "$HOME/.ssh/config" ]; then
        echo "Removing existing symlink for SSH config..."
        rm "$HOME/.ssh/config"
    fi

    # Ensure SSH config file exists and has correct permissions
    if [ ! -f "$HOME/.ssh/config" ]; then
        echo "Creating SSH config file..."
        touch "$HOME/.ssh/config"
        chmod 600 "$HOME/.ssh/config"
    else
        echo "SSH config file already exists. Ensuring correct permissions..."
        chmod 600 "$HOME/.ssh/config"
    fi

    # Personal SSH key
    read -p "Enter your personal email: " personal_email
    read -p "Enter your personal name: " personal_name
    read -p "Enter your personal GitHub hostname (e.g., github.com): " personal_hostname

    # Work SSH key
    read -p "Enter your work email: " work_email
    read -p "Enter your work name: " work_name
    read -p "Enter your work Git hostname: " work_hostname

    # Create SSH keys if they don't exist
    create_ssh_key "$personal_email" "$HOME/.ssh/id_rsa_personal"
    create_ssh_key "$work_email" "$HOME/.ssh/id_rsa_work"

    # Update SSH config
    update_ssh_config "github.com" "$personal_hostname" "~/.ssh/id_rsa_personal"
    update_ssh_config "github-work" "$work_hostname" "~/.ssh/id_rsa_work"

    # Add SSH keys to ssh-agent
    eval "$(ssh-agent -s)"

    # Create SSH config directory if it doesn't exist
    mkdir -p ~/.ssh/config.d

    # Create a more comprehensive SSH config
    cat > ~/.ssh/config.d/github <<EOF
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_personal
    AddKeysToAgent yes
    UseKeychain yes

Host github-work
    HostName $work_hostname
    User git
    IdentityFile ~/.ssh/id_rsa_work
    AddKeysToAgent yes
    UseKeychain yes
EOF

    # Include the config.d directory in the main config
    if ! grep -q "Include config.d/\*" ~/.ssh/config; then
        echo "Include config.d/*" | cat - ~/.ssh/config > temp && mv temp ~/.ssh/config
    fi

    # Set correct permissions
    chmod 600 ~/.ssh/config.d/*
    chmod 600 ~/.ssh/config

    # Display SSH public keys
    echo "Add these SSH public keys to your GitHub accounts:"
    echo "Personal SSH key:"
    cat ~/.ssh/id_rsa_personal.pub
    echo "Work SSH key:"
    cat ~/.ssh/id_rsa_work.pub
fi

# GPG setup
if ask_yes_no "Do you want to set up GPG keys?"; then
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
    personal_gpg=$(gpg --list-secret-keys --keyid-format LONG "$personal_email" | grep sec | head -n 1 | awk '{print $2}' | cut -d'/' -f2)
    work_gpg=$(gpg --list-secret-keys --keyid-format LONG "$work_email" | grep sec | head -n 1 | awk '{print $2}' | cut -d'/' -f2)

    # Display GPG public keys
    echo "Add these GPG public keys to your GitHub accounts:"
    echo "Personal GPG key:"
    gpg --armor --export $personal_gpg
    echo "Work GPG key:"
    gpg --armor --export $work_gpg
fi

# Git config setup
if ask_yes_no "Do you want to configure Git?"; then
    # Update Git configs
    update_git_config ~/.gitconfig-personal "$personal_name" "$personal_email" "$personal_gpg"
    update_git_config ~/.gitconfig-work "$work_name" "$work_email" "$work_gpg"

    # Configure global Git settings
    git config --global core.editor "nvim"
    git config --global core.pager "delta"
    git config --global core.excludesfile "~/.gitignore_global"

    git config --global interactive.diffFilter "delta --color-only"

    git config --global delta.navigate "true"
    git config --global delta.light "false"
    git config --global delta.side-by-side "true"

    git config --global merge.conflictstyle "diff3"

    git config --global diff.colorMoved "default"

    git config --global alias.co "checkout"
    git config --global alias.br "branch"
    git config --global alias.ci "commit"
    git config --global alias.st "status"
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

    # Set personal user and email as default
    git config --global user.name "$personal_name"
    git config --global user.email "$personal_email"

    # Ensure the main .gitconfig has the correct includes
    git config --global --remove-section includeIf.gitdir:~/personal 2>/dev/null || true
    git config --global --add includeIf.gitdir:~/personal.path ~/.gitconfig-personal

    git config --global --remove-section includeIf.gitdir:~/work 2>/dev/null || true
    git config --global --add includeIf.gitdir:~/work.path ~/.gitconfig-work

    # Configure Git to use GPG signing
    git config --global commit.gpgsign true
    git config --global user.signingkey "$personal_gpg"
fi

echo "Git setup complete."
echo "Remember to add your public SSH and GPG keys to your GitHub accounts if you set them up!"
echo "You may want to add 'export GPG_TTY=\$(tty)' to your .zshrc or .bash_profile to ensure GPG can prompt for passwords."
