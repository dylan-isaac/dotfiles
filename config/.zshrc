# ==========================================================
# Modern ZSH Configuration
# Optimized for performance and developer happiness
# ==========================================================

# -----------------------------
# 1. Core ZSH Configuration
# -----------------------------
# Better history
setopt HIST_VERIFY
setopt EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Better directory navigation
setopt AUTO_CD              # cd by just typing directory
setopt AUTO_PUSHD          # push directories on every cd
setopt PUSHD_IGNORE_DUPS   # don't push duplicates

# -----------------------------
# 2. Package Management
# -----------------------------
# Ensure Homebrew commands are available
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null

# -----------------------------
# 3. Environment Variables
# -----------------------------
export EDITOR='vim'
export VISUAL='vim'
export PROJECTS=~/Projects

# Use bat as manpager for colored man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# -----------------------------
# 4. Path Configuration
# -----------------------------
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# -----------------------------
# 5. Tool Configuration
# -----------------------------

# UV - Modern Python Package Manager
# Setting UV as the default Python package manager
export UV_PYTHON_DEFAULT_TOOL=1

# Ensure Python related paths are available
export PATH="$HOME/.local/bin:$PATH"            # User-installed Python packages
[ -d "$HOME/.pyenv/bin" ] && export PATH="$HOME/.pyenv/bin:$PATH"  # pyenv if installed

# Ensure Rust/Cargo paths are available for UV
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"

# UV aliases - Python package management
alias uvpip="uv pip"
alias uvvenv="uv venv"
alias uvrun="uv run"
alias uvinstall="uv pip install"

# oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf
)
source $ZSH/oh-my-zsh.sh

# Homebrew
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
    autoload -Uz compinit
    compinit
fi

# Node Version Manager (NVM)
export NVM_DIR="$HOME/.nvm"
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
    # Lazy load nvm for faster shell startup
    nvm() {
        unset -f nvm
        source "/opt/homebrew/opt/nvm/nvm.sh"
        source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
        nvm "$@"
    }
fi

# Python Environment
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null && {
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
}

# UV - Modern Python Package Manager
export UV_SYSTEM_PYTHON=false    # Don't use system Python by default

# Python aliases - use UV instead of pip
alias uvpipx="uv pipx"
alias uvuninstall="uv pip uninstall"
alias uvlist="uv pip list"
alias uvfreeze="uv pip freeze"

# Python environment functions
function create-venv() {
    local venv_path="${1:-.venv}"
    local activate_venv="${2:-true}"
    
    # Check if venv already exists
    if [ -d "$venv_path" ]; then
        echo "Virtual environment already exists at $venv_path"
    else
        echo "Creating virtual environment at $venv_path..."
        uv venv "$venv_path"
        echo "Virtual environment created at $venv_path"
    fi
    
    # Check if we should activate the venv
    if [ "$activate_venv" = true ]; then
        # Check if we're already in a virtual environment
        if [ -n "$VIRTUAL_ENV" ]; then
            echo "Already in virtual environment: $VIRTUAL_ENV"
            echo "Deactivate first with 'deactivate' if you want to switch"
        else
            echo "Activating virtual environment..."
            source "$venv_path/bin/activate"
            echo "Virtual environment activated"
        fi
    else
        echo "Activate with: source $venv_path/bin/activate"
    fi
}

# -----------------------------
# 6. Modern CLI Alternatives
# -----------------------------
# Modern ls replacement (eza)
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --group-directories-first'

# Modern cat replacement (bat)
alias cat='bat --paging=never'

# Modern cd replacement (zoxide)
eval "$(zoxide init zsh)"

# FZF Configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# -----------------------------
# 7. Custom Functions
# -----------------------------
# Quick project navigation
function p() {
    cd "$PROJECTS/$1"
}

# Create and enter directory
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
function extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)          echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# -----------------------------
# 8. Local Configuration
# -----------------------------
# Source local configuration if it exists
[ -f ~/.localrc ] && source ~/.localrc

# Source machine-specific configuration with API keys and settings
# This file is not tracked in git - see .zshrc.local.template for reference
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# iTerm2 Integration
[ -f "${HOME}/.iterm2_shell_integration.zsh" ] && source "${HOME}/.iterm2_shell_integration.zsh"

# -----------------------------
# 9. Starship Prompt
# -----------------------------
# Initialize starship prompt
eval "$(starship init zsh)"

# -----------------------------
# 10. AI Coding Tools
# -----------------------------
# AI coding tools configuration and aliases
# For full configuration, see the AI Coding Tools section in README.md

# Basic aliases for AI coding tools - uncomment and customize as needed
# alias aider='aider --temperature 0.0'  # Lower temperature for more deterministic responses
# alias goose='goose'                    # Block's AI development tool

# Examples of helpful AI tool aliases (uncomment and modify as needed)
# alias ai-code='aider --model gpt-4o'  # Example: Quick access to preferred AI coding assistant
# alias explain='goose explain -f'      # Example: Explain code in a file

# Example of a simple AI helper function
# function ai-help() {
#   echo "========== AI Coding Assistant Commands =========="
#   echo "See the AI Coding Tools section in README.md for complete documentation"
#   echo "Remember to configure your API keys in ~/.zshrc.local"
# }

# Example helper functions (uncomment and modify as needed)
# 
# # Clone a repo and start aider with it
# function aider-repo() {
#   local repo_url="$1"
#   local branch="${2:-main}"
#   local temp_dir=$(mktemp -d)
#   
#   echo "Cloning $repo_url ($branch) to $temp_dir..."
#   git clone --branch "$branch" "$repo_url" "$temp_dir"
#   
#   echo "Starting aider with the repository..."
#   cd "$temp_dir" && aider
# }

# -----------------------------
# 11. Custom Configuration
# -----------------------------
# Add your custom configurations below this line