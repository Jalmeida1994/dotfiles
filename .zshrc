# Setup Homebrew
if [[ $(uname -m) == 'arm64' ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"  # This loads nvm
[ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix nvm)/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Ensure NVM-managed Node.js is used
if [ -s "$NVM_DIR/nvm.sh" ]; then
  export PATH="$NVM_DIR/versions/node/$(nvm version)/bin:$PATH"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Enable command auto-corrections
ENABLE_CORRECTION="true"

# Oh My Zsh plugins
plugins=(git docker kubectl fzf gh)

source $ZSH/oh-my-zsh.sh

# Zinit installation and setup
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load Zinit annexes
zinit light-mode for \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node

# Load additional plugins with Zinit
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-completions

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# Tfenv
export PATH="$HOME/.tfenv/bin:$PATH"

# Jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Direnv
eval "$(direnv hook zsh)"

# Initialize goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"

# Add Go binaries to PATH
export PATH="$PATH:$(go env GOPATH)/bin"

# Initialize thefuck for command correction (if installed)
eval $(thefuck --alias)

# Use ripgrep with FZF
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

# Improved history searching
bindkey '^R' history-incremental-pattern-search-backward

# Auto-suggest accepts with right arrow
bindkey '^ ' autosuggest-accept

# Use starship prompt
eval "$(starship init zsh)"

# Set DOCKER_HOST to colima.sock
export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"

# Aliases
alias update='brew update && brew upgrade'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias ls='eza --icons --git'
alias cat='bat --style=auto'
alias grep='rg'
alias find='fd'

# Git aliases
alias gs='git status'
alias gd='git diff'
alias gco='git checkout'
alias gaa='git add --all'
alias gc='git commit -v'
alias gl='git pull'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'

# Terraform aliases
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'

# Docker aliases
alias docker-clean='docker system prune -af'
alias docker-rmi='docker rmi $(docker images -q)'
alias docker-rm='docker rm $(docker ps -aq)'
alias docker-stop='docker stop $(docker ps -aq)'
alias use-docker-context='docker context use $1 && set-docker-host'

# Functions
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Add Rust to PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Use fzf for fuzzy file and history search
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
