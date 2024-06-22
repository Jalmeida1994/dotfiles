# Dotfiles

Welcome to my personal dotfiles repository! This collection of configuration files and scripts is designed to quickly set up a consistent and productive MacOS development environment. Whether you're setting up a new machine or just looking to improve your current setup, these dotfiles have got you covered.

## What's Included

This repository contains configurations for:

- Zsh (shell)
- Git
- Vim and Neovim
- tmux
- Visual Studio Code
- Alacritty (terminal emulator)
- Various development tools (pyenv, nvm, jenv, etc.)
- A curated list of Homebrew packages and casks

## Key Features

- **One-Command Setup**: Get your entire development environment configured with a single script.
- **Modular Configuration**: Easily customize or extend the setup to suit your needs.
- **Git Profile Management**: Separate configurations for personal and work Git profiles.
- **Visual Studio Code Integration**: Synced settings and extensions for VS Code.
- **MacOS Preferences**: Sensible defaults for MacOS to enhance productivity.

## Installation

1. Clone this repository:

   ```
   git clone https://github.com/Jalmeida1994/dotfiles.git ~/dotfiles
   ```

2. Navigate to the dotfiles directory:

   ```
   cd ~/dotfiles
   ```

3. Run the setup script:

   ```
   ./setup.sh
   ```

4. (Optional) Set up SSH and GPG keys:
   If you choose 'yes' when prompted during setup, the script will guide you through creating SSH and GPG keys for secure Git operations.

5. Restart your terminal or run `source ~/.zshrc` to apply the changes.

## What the Setup Does

The `setup.sh` script performs the following actions:

1. Symlinks configuration files to your home directory.
2. Installs Homebrew if not already present.
3. Installs a curated list of Homebrew packages and casks.
4. Sets Zsh as the default shell.
5. Configures fzf for fuzzy finding.
6. Applies custom MacOS preferences.
7. Sets up a global gitignore file.
8. Installs Visual Studio Code extensions.
9. Installs Neovim plugins.
10. Optionally sets up SSH and GPG keys for Git.

## Customization

Feel free to fork this repository and modify any configurations to suit your needs. Here are some common customization points:

- **Homebrew Packages**: Edit the `Brewfile` to add or remove packages.
- **Zsh Configuration**: Modify `.zshrc` to change shell behavior, aliases, or add new functions.
- **Git Configuration**: Adjust `.gitconfig`, `.gitconfig-personal`, and `.gitconfig-work` for your Git preferences.
- **VS Code Settings**: Update `vscode/settings.json` and `vscode/extensions.txt` for your ideal VS Code setup.
- **Vim/Neovim**: Customize `.vimrc` or `.config/nvim/init.lua` for your editor preferences.

## Maintaining Your Dotfiles

To keep your dotfiles up to date:

1. Make changes to the relevant files in your `~/dotfiles` directory.
2. Commit and push your changes to your GitHub repository.
3. On other machines, pull the latest changes and re-run `./setup.sh`.

## Optional: SSH and GPG Setup

If you choose to set up SSH and GPG keys during the installation:

1. The script will generate new SSH keys for personal and work use.
2. It will also create GPG keys for signing your Git commits.
3. Follow the prompts to enter your information.
4. After setup, add the displayed public keys to your GitHub account(s).

## Troubleshooting

- If you encounter any issues during setup, check the console output for error messages.
- Ensure you have sufficient permissions to install software on your machine.
- For problems with specific tools, consult their respective documentation.

## Contributing

If you have suggestions for improving these dotfiles, please open an issue or submit a pull request. Contributions are always welcome!

## License

This project is open source and available under the [MIT License](LICENSE).

Happy coding! 🚀

[Back to Top ⬆️](#dotfiles)
