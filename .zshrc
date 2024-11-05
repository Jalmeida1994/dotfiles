# Setup Homebrew
if [[ $(uname -m) == 'arm64' ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

# SSH Agent configuration
ssh_agent_start() {
    # Create runtime directory if it doesn't exist
    if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
        mkdir -p "$XDG_RUNTIME_DIR"
        chmod 700 "$XDG_RUNTIME_DIR"
    fi

    # Check if ssh-agent is already running
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        # Start new agent and save environment variables
        ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
    fi

    # Load environment variables if they exist
    if [[ -f "$XDG_RUNTIME_DIR/ssh-agent.env" ]]; then
        source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
    fi
}

ssh_keys_add() {
    local keys_to_add=("$HOME/.ssh/id_rsa_personal" "$HOME/.ssh/id_rsa_work")
    local keys_loaded
    keys_loaded=$(ssh-add -l)

    for key in "${keys_to_add[@]}"; do
        if [[ -f "$key" ]] && ! echo "$keys_loaded" | grep -q "$key"; then
            ssh-add "$key" 2>/dev/null
        fi
    done
}

# Create XDG_RUNTIME_DIR if it doesn't exist
if [[ -z "${XDG_RUNTIME_DIR}" ]]; then
    export XDG_RUNTIME_DIR="/tmp/${UID}-runtime-dir"
    if ! [[ -d "${XDG_RUNTIME_DIR}" ]]; then
        mkdir -m 0700 -p "${XDG_RUNTIME_DIR}"
    fi
fi

# Start SSH agent and add keys
ssh_agent_start
ssh_keys_add

# Basic ZSH configuration
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt SHARE_HISTORY            # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS         # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS     # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS        # Do not display a line previously found.
setopt HIST_SAVE_NO_DUPS        # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY              # Don't execute immediately upon history expansion.
setopt AUTO_CD                  # If a command is issued that can't be executed as a normal command,
                               # and the command is the name of a directory, perform the cd command to that directory.

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

# Load essential plugins in turbo mode
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start; bindkey '^ ' autosuggest-accept" \
    zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions

# Load Git plugin and completions
zinit ice wait lucid
zinit snippet OMZP::git

# Load additional useful plugins
zinit wait lucid for \
    OMZP::colored-man-pages \
    OMZP::command-not-found

# Docker completions
zinit ice wait lucid as"completion"
zinit snippet https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker

# Docker-compose completions
zinit ice wait lucid as"completion"
zinit snippet https://raw.githubusercontent.com/docker/compose/master/contrib/completion/zsh/_docker-compose

# NVM lazy loading
export NVM_DIR="$HOME/.nvm"
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true

nvm() {
    unset -f nvm node npm
    [ -s "$(brew --prefix nvm)/nvm.sh" ] && source "$(brew --prefix nvm)/nvm.sh"
    nvm "$@"
}

node() {
    unset -f nvm node npm
    [ -s "$(brew --prefix nvm)/nvm.sh" ] && source "$(brew --prefix nvm)/nvm.sh"
    node "$@"
}

npm() {
    unset -f nvm node npm
    [ -s "$(brew --prefix nvm)/nvm.sh" ] && source "$(brew --prefix nvm)/nvm.sh"
    npm "$@"
}

# Lazy load development environment managers
function load_pyenv() {
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
}

function load_jenv() {
    eval "$(jenv init -)"
}

function load_goenv() {
    eval "$(goenv init -)"
}

# Create wrapper functions
python() {
    load_pyenv
    unset -f python
    python "$@"
}

java() {
    load_jenv
    unset -f java
    java "$@"
}

go() {
    load_goenv
    unset -f go
    go "$@"
}

# Defer direnv loading
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"

# Load thefuck only when needed
fuck() {
    eval $(thefuck --alias)
    fuck "$@"
}

# FZF configuration
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Key bindings
bindkey '^R' history-incremental-pattern-search-backward

# Docker configuration
export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
export DOCKER_BUILDKIT=1

# Path additions
export PATH="$HOME/.cargo/bin:$PATH"

# Initialize starship prompt
eval "$(starship init zsh)"

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
