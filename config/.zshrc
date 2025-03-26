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
        local node_version="${2:-lts}"
        local project_type="${3:-basic}"  # basic, react, express, typescript
        
        # Create project directory
        if [ -d "$project_name" ]; then
            echo "Directory $project_name already exists. Overwrite? (y/n): "
            read overwrite
            if [[ ! $overwrite =~ ^[Yy]$ ]]; then
                echo "Operation cancelled."
                return 1
            fi
        fi
        
        mkdir -p "$project_name"
        cd "$project_name" || return
        
        # Set up Node version
        if [[ "$node_version" == "lts" || "$node_version" == "lts/*" ]]; then
            # Handle LTS specifically
            nvm install --lts
            nvm use --lts
            # Store the actual version number in .nvmrc rather than "lts"
            node -v > .nvmrc
        else
            # Handle specific version or other aliases
            nvm install "$node_version"
            nvm use "$node_version"
            echo "$node_version" > .nvmrc
        fi
        
        # Initialize package.json
        npm init -y
        
        # Set up project based on type
        case "$project_type" in
            react)
                echo "Setting up React project..."
                npx create-react-app .
                ;;
            express)
                echo "Setting up Express project..."
                npm install express
                mkdir -p src
                
                # Create a basic Express app.js
                cat > src/app.js << EOF
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  console.log(\`Server listening at http://localhost:\${port}\`);
});
EOF
                
                # Update package.json
                jq '.scripts.start = "node src/app.js"' package.json > temp.json && mv temp.json package.json
                ;;
            typescript)
                echo "Setting up TypeScript project..."
                npm install typescript @types/node --save-dev
                npx tsc --init
                
                mkdir -p src
                
                # Create a basic TypeScript index.ts
                cat > src/index.ts << EOF
function greet(name: string): string {
  return \`Hello, \${name}!\`;
}

console.log(greet('World'));
EOF
                
                # Update package.json
                jq '.scripts.build = "tsc" | .scripts.start = "node dist/index.js"' package.json > temp.json && mv temp.json package.json
                ;;
            *)
                # Basic project - create a minimal structure
                echo "Setting up basic Node.js project..."
                mkdir -p src
                
                # Create a simple index.js
                cat > src/index.js << EOF
console.log('Hello, world!');
EOF
                
                # Update package.json
                jq '.scripts.start = "node src/index.js"' package.json > temp.json && mv temp.json package.json
                ;;
        esac
        
        # Create .gitignore
        cat > .gitignore << EOF
# Node modules
node_modules/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build directories
dist/
build/

# OS files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOF
        
        # Create README.md
        cat > README.md << EOF
# ${project_name}

## Description
A Node.js project.

## Installation
\`\`\`bash
npm install
\`\`\`

## Usage
\`\`\`bash
npm start
\`\`\`
EOF
        
        echo "Node project '${project_name}' created with Node version $(node -v)"
        echo "Project type: ${project_type}"
        echo ""
        echo "To get started:"
        echo "  cd ${project_name}"
        echo "  npm install"
        echo "  npm start"
    }
    
    # Load NVM functions without initializing NVM (for faster startup)
    source "/opt/homebrew/opt/nvm/nvm.sh" --no-use >/dev/null 2>&1
    
    # Activate the correct Node version automatically when changing directories
    autoload -U add-zsh-hook
    load-nvmrc() {
        local nvmrc_path=""
        
        # Safely try to find nvmrc 
        if type nvm_find_nvmrc >/dev/null 2>&1; then
            nvmrc_path="$(nvm_find_nvmrc)"
        else
            # Fallback method if nvm_find_nvmrc isn't available
            if [[ -f .nvmrc && -r .nvmrc ]]; then
                nvmrc_path=".nvmrc"
            fi
        fi
        
        if [ -n "$nvmrc_path" ]; then
            local nvmrc_node_version=$(cat "${nvmrc_path}")
            
            # Load NVM fully if it hasn't been loaded yet
            if ! type nvm >/dev/null 2>&1 || [ "$(type nvm)" = "nvm is a shell function" ]; then
                unset -f nvm >/dev/null 2>&1
                source "/opt/homebrew/opt/nvm/nvm.sh" --no-use
            fi
            
            # Check if version needs changing
            if [ "$nvmrc_node_version" != "$(nvm version)" ]; then
                nvm use &> /dev/null
            fi
        fi
    }
    
    # Hook into directory change
    add-zsh-hook chpwd load-nvmrc
    
    # Initial load at startup (only if we're in a directory with .nvmrc)
    if [[ -f .nvmrc ]]; then
        load-nvmrc
    fi
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
        echo "Do you want to recreate it? (y/n): "
        read recreate
        if [[ $recreate =~ ^[Yy]$ ]]; then
            echo "Removing existing environment..."
            rm -rf "$venv_path"
            echo "Creating virtual environment at $venv_path..."
            uv venv "$venv_path"
            echo "Virtual environment created at $venv_path"
        else
            echo "Using existing virtual environment."
        fi
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
            if [ "$VIRTUAL_ENV" != "$(pwd)/$venv_path" ]; then
                echo "Switch to new environment? (y/n): "
                read switch
                if [[ $switch =~ ^[Yy]$ ]]; then
                    deactivate
                    source "$venv_path/bin/activate"
                    echo "Switched to new virtual environment"
                fi
            fi
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

# Source generated aliases from current profile if it exists
[ -f ~/.config/dotfiles/aliases ] && source ~/.config/dotfiles/aliases

# Profile management
DOTFILES_DIR="$HOME/Projects/dotfiles"
# Load current profile if available
if [ -f "$DOTFILES_DIR/config/.current_profile" ]; then
    export DOTFILES_PROFILE=$(cat "$DOTFILES_DIR/config/.current_profile")
else
    export DOTFILES_PROFILE="personal"
fi

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

# Custom function for repomix with reliable clipboard copy
function run-repomix() {
    local output_file="repomix-output.txt"
    local style=${1:-"plain"}
    local compress=${2:-"--compress"}
    local remove_empty=${3:-"--remove-empty-lines"}
    
    # Run repomix with specified options
    npx repomix --style "$style" $compress $remove_empty -o "$output_file"
    
    # Check if file was created
    if [ -f "$output_file" ]; then
        # Copy to clipboard based on OS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            cat "$output_file" | pbcopy
            echo "✅ Copied to clipboard"
        elif command -v xclip &> /dev/null; then
            # Linux with xclip
            cat "$output_file" | xclip -selection clipboard
            echo "✅ Copied to clipboard"
        elif command -v clip &> /dev/null; then
            # Windows
            cat "$output_file" | clip
            echo "✅ Copied to clipboard"
        else
            echo "⚠️ Clipboard copy not supported on this system"
        fi
        
        # Clean up
        rm "$output_file"
    else
        echo "⚠️ Failed to generate repomix output"
    fi
}

# Core repomix aliases with custom functions for reliable clipboard use
alias context='run-repomix xml'             # XML format with compression
alias context-md='run-repomix markdown'     # Markdown with compression
alias context-full='run-repomix xml ""'     # XML without compression (full code)

# Common AI tool aliases
alias coder='aider --model gpt-4o'          # Quick access to preferred AI coding assistant

# AI Developer Workflow aliases
alias adw="python $DOTFILES_DIR/bin/adw-create.py"
alias ai-workflow="python $DOTFILES_DIR/bin/adw-create.py"

# -----------------------------
# 11. Custom Configuration
# -----------------------------
# Add your custom configurations below this line
