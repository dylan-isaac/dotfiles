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
    
    # Enhanced npx that respects project Node version
    npx() {
        if [ -f .nvmrc ] || [ -f .node-version ] || [ -f package.json ]; then
            # Unset the lazy-loaded function so we load nvm properly
            unset -f nvm
            source "/opt/homebrew/opt/nvm/nvm.sh" --no-use
            
            # Switch to the project's Node version before running npx
            nvm use &> /dev/null
            # Run npx with the project's Node version
            command npx "$@"
            
            # Optionally, switch back to default
            # nvm use default &> /dev/null
        else
            command npx "$@"
        fi
    }
    
    # Create a new Node project with proper setup
    function create-node-project() {
        local project_name="${1:?Project name is required}"
        local node_version="${2:-lts/*}"
        
        # Create project directory
        mkdir -p "$project_name"
        cd "$project_name" || return
        
        # Set up Node version
        nvm install "$node_version"
        nvm use "$node_version"
        echo "$node_version" > .nvmrc
        
        # Initialize package.json
        npm init -y
        
        echo "Node project '$project_name' created with Node version $(node -v)"
        echo "To get started:"
        echo "  cd $project_name"
        echo "  npm install your-dependencies"
    }
    
    # Activate the correct Node version automatically when changing directories
    autoload -U add-zsh-hook
    load-nvmrc() {
        local nvmrc_path="$(nvm_find_nvmrc)"
        
        if [ -n "$nvmrc_path" ]; then
            local nvmrc_node_version=$(cat "${nvmrc_path}")
            
            if [ "$nvmrc_node_version" = "$(nvm version)" ]; then
                # Version is already correct
                return
            fi
            
            # Load NVM if not already loaded
            unset -f nvm
            source "/opt/homebrew/opt/nvm/nvm.sh" --no-use
            
            # Switch to the correct version
            nvm use &> /dev/null
        fi
    }
    add-zsh-hook chpwd load-nvmrc
    load-nvmrc
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

# Basic AI coding tool aliases
alias aider='aider --temperature 0.0'  # Lower temperature for more deterministic responses
alias goose='goose'                    # Block's AI development tool

# Repomix configuration and aliases
# Core repomix alias - optimized for clipboard use with standard settings
alias repomix='npx repomix --copy --style xml --compress --remove-empty-lines'

# Additional specialized repomix aliases
alias repomix-clip='repomix --copy'                   # Copy output to clipboard
alias repomix-explain='repomix --instruction-file-path .repomix-explain.md'  # Add explain instructions
alias repomix-compress='repomix --compress'           # Use the compression mode
alias repomix-mcp='repomix --mcp'                     # Start MCP server
alias repomix-remote='repomix --remote'               # Process remote repository

# Quickly create a repomix instruction file
function repomix-init-explain() {
  cat > .repomix-explain.md << 'EOF'
# Repository Analysis Instructions

Please analyze this codebase with the following focus:

1. Application structure and architecture
2. Main components and their responsibilities
3. Key data flows and interactions
4. Suggested improvements or refactoring opportunities
5. Potential bugs or issues

Please ignore test files and focus on the core application logic.
EOF
  echo "Created .repomix-explain.md in the current directory"
  echo "Use 'repomix-explain' to include these instructions with the codebase"
}

# Common AI tool aliases
alias ai-code='aider --model gpt-4o'   # Quick access to preferred AI coding assistant
alias ai-explain='goose explain -f'    # Explain code in a file
alias ai-context='repomix'             # Copy codebase context to clipboard

# Example of a simple AI helper function
function ai-help() {
  echo "========== AI Coding Assistant Commands =========="
  echo "ai-code    - Start AI coding assistant with GPT-4o"
  echo "ai-explain - Explain code in a file"
  echo "ai-context - Generate context from codebase (with repomix)"
  echo "aider      - Start aider with lower temperature"
  echo "goose      - Block's AI development tool"
  echo "repomix    - Generate codebase context for LLMs"
  echo "repomix-mcp - Start repomix MCP server for AI assistants"
  echo ""
  echo "See the AI Coding Tools section in README.md for complete documentation"
  echo "API keys should be configured in ~/.zshrc.local"
}

# Additional helper functions (uncomment and modify as needed)
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