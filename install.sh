#!/bin/zsh

# Set script to exit on error
set -e

DOTFILES_DIR="$HOME/Projects/dotfiles"
CONFIG_DIR="$DOTFILES_DIR/config"
LOCAL_CONFIG_DIR="$CONFIG_DIR/local"
BREW_CONFIG_DIR="$CONFIG_DIR/brew"

# Enhanced backup directory with sequence number to prevent overwrites
BACKUP_DATE="$(date +%Y%m%d_%H%M%S)"
BACKUP_SEQ=1
BACKUP_DIR="$HOME/.dotfiles.backup.$BACKUP_DATE"
while [ -d "$BACKUP_DIR" ]; do
    BACKUP_SEQ=$((BACKUP_SEQ+1))
    BACKUP_DIR="$HOME/.dotfiles.backup.$BACKUP_DATE.$BACKUP_SEQ"
done

SKIP_APPS=false
QUICK_MODE=false
CONFIG_ONLY=false
PROFILE="personal"  # Default profile

# Text formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --skip-apps) SKIP_APPS=true ;;
        --quick) QUICK_MODE=true ;;
        --config-only) CONFIG_ONLY=true ;;
        --profile=*) PROFILE="${1#*=}" ;;
        --profile) 
            if [[ -n "$2" && "$2" != --* ]]; then
                PROFILE="$2"
                shift
            else
                log "error" "No profile specified for --profile option"
                exit 1
            fi
            ;;
        --help) 
            echo "Usage: ./install.sh [options]"
            echo "Options:"
            echo "  --skip-apps            Skip installation of applications"
            echo "  --quick                Skip all Homebrew operations and installations that are already complete"
            echo "  --config-only          Only perform symlinks and configuration, no installations"
            echo "  --profile=<n>          Use specific profile for configuration (personal, work, server)"
            echo "  --profile <n>          Use specific profile for configuration (personal, work, server)"
            echo "  --help                 Show this help message"
            exit 0
            ;;
        *) echo -e "${RED}Unknown parameter: $1${NC}"; exit 1 ;;
    esac
    shift
done

# Save the current profile for reference
echo "$PROFILE" > "$DOTFILES_DIR/.current_profile"

# Set WORK_ENV based on profile
if [ "$PROFILE" = "work" ]; then
    WORK_ENV=true
fi

# Log function with timestamps
log() {
    local level="$1"
    local message="$2"
    
    case "$level" in
        "info") echo -e "${BLUE}[INFO]${NC} $message" ;;
        "success") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "warn") echo -e "${YELLOW}[WARNING]${NC} $message" ;;
        "error") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
}

# Critical error function - prints error and exits
critical_error() {
    log "error" "$1"
    log "error" "Installation cannot continue. Please fix the issue and try again."
    exit 1
}

# Function to create symbolic links
link_file() {
    local src=$1
    local dest=$2
    local backup_dir=$3

    # If the destination file exists and is not a symlink
    if [ -f "$dest" ] && [ ! -L "$dest" ]; then
        log "info" "Backing up $dest to $backup_dir/"
        mkdir -p "$backup_dir"
        mv "$dest" "$backup_dir/"
    fi

    # Create the symbolic link
    if [ ! -L "$dest" ]; then
        log "info" "Linking $src to $dest"
        ln -sf "$src" "$dest"
    fi
}

# Check for required system tools
check_system_requirements() {
    log "info" "Checking system requirements..."
    
    # Check for Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        log "warn" "Command Line Tools not found. Installing..."
        xcode-select --install || critical_error "Failed to install Command Line Tools"
        log "warn" "After Command Line Tools installation completes, please run this script again."
        exit 0
    else
        log "success" "Command Line Tools are installed"
    fi
}

# Install and configure Homebrew
setup_homebrew() {
    log "info" "Setting up Homebrew..."
    
    # Skip homebrew setup in quick mode
    if [ "$QUICK_MODE" = true ]; then
        log "info" "Quick mode enabled - skipping Homebrew setup"
        # Just ensure Homebrew is in PATH if it exists
        if command -v brew &>/dev/null; then
            log "success" "Homebrew is already installed and will be used for essential operations only"
            eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
        else
            log "warn" "Homebrew is not installed. Some features may not work in quick mode."
        fi
        return 0
    fi
    
    # Install Homebrew if not installed
    if ! command -v brew &>/dev/null; then
        log "info" "Installing Homebrew..."
        /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || critical_error "Failed to install Homebrew"
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
    else
        log "success" "Homebrew is already installed"
    fi

    # Update Homebrew
    log "info" "Updating Homebrew..."
    brew update || log "warn" "Failed to update Homebrew, continuing anyway"
    
    # Verify Homebrew is working properly
    if ! brew doctor &>/dev/null; then
        log "warn" "Homebrew has issues that may affect installation."
        
        # Get the full output for analysis
        local doctor_output=$(brew doctor 2>&1)
        
        # Check for common known issues that can be safely ignored
        if echo "$doctor_output" | grep -q "pkg-config" && echo "$doctor_output" | grep -q "pkgconf"; then
            log "info" "Detected common pkg-config/pkgconf conflict - this is normal and can be ignored"
            log "info" "This means you have both pkg-config and pkgconf installed, which is fine"
            log "info" "After installation, you can choose which one to use with 'brew unlink pkgconf && brew link pkg-config'"
        # Check for unlinked kegs specifically
        elif echo "$doctor_output" | grep -q "unlinked kegs"; then
            local unlinked_kegs=$(echo "$doctor_output" | grep -A 20 "unlinked kegs" | grep -B 20 "Run \`brew link\` on these:" | grep "  " | tr -d ' ')
            
            if [[ -n "$unlinked_kegs" ]]; then
                log "info" "Found unlinked kegs: $unlinked_kegs"
                log "info" "Attempting to link unlinked kegs automatically..."
                
                for keg in $unlinked_kegs; do
                    log "info" "Linking $keg..."
                    brew link "$keg" 2>/dev/null || log "warn" "Failed to link $keg, continuing anyway"
                done
                
                log "info" "Finished linking kegs"
            fi
        else
            # General issues that weren't automatically fixed, show full output
            log "warn" "Homebrew has issues that couldn't be automatically fixed:"
            echo "$doctor_output"
            
            # Use printf instead of read -p for better shell compatibility
            printf "Continue with installation? (y/n) "
            read answer
            if [[ ! $answer =~ ^[Yy]$ ]]; then
                critical_error "Installation aborted by user due to Homebrew issues"
            fi
        fi
    fi
}

# Install core development tools
install_core_tools() {
    log "info" "Installing core development tools..."
    
    # Skip Homebrew installations in quick mode
    if [ "$QUICK_MODE" = true ]; then
        log "info" "Quick mode enabled - skipping Homebrew installations of core tools"
        
        # Only check if tools are available
        for cmd in git python3 pyenv; do
            if command -v $cmd &>/dev/null; then
                log "success" "$cmd is already installed"
            else
                log "warn" "$cmd is not installed. Some functionality may be limited in quick mode."
            fi
        done
        
        log "info" "Core tools check complete"
        return 0
    fi
    
    # Install Git (required for remaining steps)
    if ! command -v git &>/dev/null; then
        log "info" "Installing Git..."
        brew install git || critical_error "Failed to install Git"
        
        # Verify Git installation
        if ! command -v git &>/dev/null; then
            critical_error "Git installation failed or Git not found in PATH"
        fi
    else
        log "success" "Git is already installed"
    fi
    
    # Install Python
    if ! command -v python3 &>/dev/null; then
        log "info" "Installing Python..."
        brew install python || critical_error "Failed to install Python"
        
        # Verify Python installation
        if ! command -v python3 &>/dev/null; then
            critical_error "Python installation failed or Python not found in PATH"
        fi
    else
        log "success" "Python is already installed: $(python3 --version)"
    fi
    
    # Install pyenv for Python version management
    if ! command -v pyenv &>/dev/null; then
        log "info" "Installing pyenv..."
        brew install pyenv || log "warn" "Failed to install pyenv"
    else
        log "success" "pyenv is already installed"
    fi
    
    log "success" "Core development tools installed successfully"
}

# Set up UV package manager
setup_uv() {
    log "info" "Setting up UV package manager..."
    
    # First check if UV is already installed
    if command -v uv &>/dev/null; then
        log "success" "UV is already installed: $(uv --version)"
        return 0
    fi
    
    # Skip UV installation in quick mode if not already installed
    if [ "$QUICK_MODE" = true ]; then
        log "info" "Quick mode enabled - skipping UV installation"
        return 0
    fi
    
    # Ensure Python is available before attempting UV installation
    if ! command -v python3 &>/dev/null; then
        log "error" "Python is required for UV installation but was not found"
        log "info" "Will attempt to continue without UV, but some features may not work"
        return 1
    fi
    
    # If Python is available, install via pip (preferred method)
    log "info" "Installing UV via pip..."
    python3 -m pip install --user uv
        
    # Check if installation succeeded
    if command -v uv &>/dev/null || [ -f "$HOME/.local/bin/uv" ]; then
        export PATH="$HOME/.local/bin:$PATH"  # Add to PATH for immediate use
        log "success" "UV installed successfully via pip"
        return 0
    else
        log "warn" "Failed to install UV via pip, trying backup installation methods"
        
        # Skip Homebrew fallback in quick mode
        if [ "$QUICK_MODE" = true ]; then
            log "info" "Quick mode enabled - skipping Homebrew fallback for UV"
            return 1
        fi
        
        # Try brew as fallback
        log "info" "Trying Homebrew installation method for UV..."
        brew install uv || {
            log "warn" "UV installation failed. Some Python functionality will be limited."
            return 1
        }
    fi
    
    # Final verification
    if command -v uv &>/dev/null; then
        log "success" "UV installed successfully: $(uv --version)"
        return 0
    else
        log "warn" "UV installation failed. Some Python functionality will be limited."
        return 1
    fi
}

# Install additional applications via Homebrew
install_applications() {
    # Skip in quick mode
    if [ "$QUICK_MODE" = true ]; then
        log "info" "Quick mode enabled - skipping all application installations"
        return 0
    fi
    
    if [ "$SKIP_APPS" = true ]; then
        log "info" "Skipping application installation (--skip-apps flag provided)"
        return 0
    fi
    
    log "info" "Checking application installations..."
    
    # Proceed with installation
    log "info" "Installing applications..."
    
    # Remove conflicting applications first
    log "info" "Checking for conflicting applications..."
    local conflicts=0
    for app in "docker" "balenaetcher" "calibre"; do
        if brew list --cask "$app" &>/dev/null; then
            log "info" "Found conflicting app: $app"
            conflicts=$((conflicts+1))
        fi
    done
    
    if [ $conflicts -gt 0 ]; then
        log "info" "Removing $conflicts conflicting applications..."
        brew uninstall --cask docker balenaetcher calibre --force 2>/dev/null || true
    fi

    # Install essential packages
    if [ "$SKIP_APPS" = false ]; then
        log "info" "Installing packages from Brewfile..."
        brew bundle --file="$BREW_CONFIG_DIR/Brewfile" || log "warn" "Some applications failed to install"
    fi
}

# Set up shell environment (Oh My Zsh, plugins)
setup_shell() {
    log "info" "Setting up shell environment..."
    
    # Install Oh My Zsh if not installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "info" "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || log "warn" "Failed to install Oh My Zsh"
    else
        log "success" "Oh My Zsh is already installed"
    fi

    # Install Zsh plugins
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        log "info" "Installing zsh-autosuggestions plugin..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || log "warn" "Failed to install zsh-autosuggestions"
    fi
    
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        log "info" "Installing zsh-syntax-highlighting plugin..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || log "warn" "Failed to install zsh-syntax-highlighting"
    fi
    
    # Set up Zsh completions
    log "info" "Setting up Zsh completions..."
    
    # Create completions directory in home if it doesn't exist
    mkdir -p "$HOME/.zsh_completions" 2>/dev/null || true
    
    # Link our completion scripts
    if [ -d "$CONFIG_DIR/zsh/completions" ]; then
        for completion_file in "$CONFIG_DIR/zsh/completions/_"*; do
            if [ -f "$completion_file" ]; then
                local completion_name=$(basename "$completion_file")
                link_file "$completion_file" "$HOME/.zsh_completions/$completion_name" "$BACKUP_DIR"
                log "info" "Linked completion: $completion_name"
            fi
        done
    else
        log "warn" "Zsh completions directory not found: $CONFIG_DIR/zsh/completions"
    fi
    
    # Add completions directory to fpath in .zshrc.local if not already there
    local zshrc_local="$LOCAL_CONFIG_DIR/.zshrc.local"
    if [ -f "$zshrc_local" ]; then
        if ! grep -q "fpath=(~/.zsh_completions \$fpath)" "$zshrc_local"; then
            log "info" "Adding completions directory to fpath in .zshrc.local"
            echo "" >> "$zshrc_local"
            echo "# Load custom completions" >> "$zshrc_local"
            echo "fpath=(~/.zsh_completions \$fpath)" >> "$zshrc_local"
            echo "autoload -Uz compinit && compinit" >> "$zshrc_local"
        else
            log "info" "Completions directory already in fpath"
        fi
    else
        log "warn" "Could not add completions to .zshrc.local: file not found"
    fi
}

# Set up AI development tools
setup_ai_tools() {
    log "info" "Setting up AI development tools..."
    
    # Check if gcc/gfortran is installed for Aider (needed for scipy)
    if ! command -v gfortran &>/dev/null && [ "$QUICK_MODE" = false ]; then
        log "info" "Installing gcc (includes gfortran) for Aider dependencies..."
        brew install gcc || log "warn" "Failed to install gcc. Aider installation might fail."
    fi
    
    # Check if AI tools should be skipped in quick mode
    if [ "$QUICK_MODE" = true ]; then
        # Only check if tools are available, don't try to install them
        log "info" "Quick mode enabled - checking for AI tools but not installing"
        
        local aider_available=false
        local goose_available=false
        local repomix_available=false
        
        if command -v aider &>/dev/null; then
            log "success" "Aider is already installed: $(aider --version 2>/dev/null || echo 'unknown version')"
            aider_available=true
        else
            log "warn" "Aider is not installed. Using AI coding assistant features will be limited in quick mode."
        fi
        
        if command -v goose &>/dev/null || [ -f "$HOME/.goose/bin/goose" ]; then
            log "success" "Goose is already installed"
            goose_available=true
            
            # Ensure Goose is in PATH for this session
            if [ -d "$HOME/.goose/bin" ]; then
                export PATH="$HOME/.goose/bin:$PATH"
            fi
        else
            log "warn" "Goose is not installed. Using AI coding assistant features will be limited in quick mode."
        fi
        
        # Check if Repomix is globally installed
        if npm list -g repomix &>/dev/null || command -v npx &>/dev/null; then
            if npm list -g repomix &>/dev/null; then
                log "success" "Repomix is already installed globally"
            else
                log "info" "Repomix can be used via npx"
            fi
            repomix_available=true
        else
            log "warn" "Repomix is not installed and npx is not available. Using AI coding assistant features will be limited in quick mode."
        fi
        
        # Set up configurations even in quick mode
        setup_ai_configurations
        
        if $aider_available && $goose_available && $repomix_available; then
            log "success" "All AI tools are available in quick mode"
        else
            log "warn" "Some AI tools are not available. Limited functionality in quick mode."
        fi
        
        return 0
    fi
    
    # Install Aider using the official install script
    if ! command -v aider &>/dev/null; then
        log "info" "Installing Aider..."
        # Use the official installation script which handles dependencies better
        curl -LsSf https://aider.chat/install.sh | sh || {
            log "warn" "Official Aider install script failed, trying alternative methods..."
            
            # Try UV if available (as a fallback)
            if command -v uv &>/dev/null; then
                log "info" "Trying UV installation method..."
                uv tool install --force aider-chat || log "warn" "UV installation failed"
            else
                # Final fallback to pip
                log "info" "Trying pip installation method..."
                python3 -m pip install aider-chat || log "warn" "Pip installation failed"
            fi
        }
        
        # Verify installation
        if command -v aider &>/dev/null; then
            log "success" "Aider installed successfully"
        else
            log "warn" "Aider installation may have failed. Please check manually."
        fi
    else
        log "success" "Aider is already installed"
    fi
    
    # Install Goose using the correct installer
    if ! command -v goose &>/dev/null && [ ! -f "$HOME/.goose/bin/goose" ]; then
        log "info" "Installing Goose..."
        
        # Create Goose directory if needed
        if [ ! -d "$HOME/.goose" ]; then
            mkdir -p "$HOME/.goose" 
            log "info" "Created Goose directory at $HOME/.goose"
        fi
        
        # Install Goose using the correct URL
        curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash || {
            log "warn" "Goose installation via official script failed"
        }
        
        # Ensure Goose is in PATH for this session
        if [ -d "$HOME/.goose/bin" ]; then
            export PATH="$HOME/.goose/bin:$PATH"
            log "info" "Added Goose to PATH for current session"
        fi
        
        # Add PATH to .zshrc.local if not already there
        if [ -f "$HOME/.zshrc.local" ]; then
            if ! grep -q 'export PATH="$HOME/.goose/bin:$PATH"' "$HOME/.zshrc.local"; then
                echo '# Add Goose to PATH' >> "$HOME/.zshrc.local"
                echo 'export PATH="$HOME/.goose/bin:$PATH"' >> "$HOME/.zshrc.local"
                log "info" "Added Goose to PATH in .zshrc.local"
            fi
        fi
        
        # Verify installation
        if command -v goose &>/dev/null || [ -f "$HOME/.goose/bin/goose" ]; then
            log "success" "Goose installed successfully"
        else
            log "warn" "Goose installation may have failed. Please check manually."
        fi
    else
        log "success" "Goose is already installed"
        
        # Ensure Goose is in PATH for this session
        if [ -d "$HOME/.goose/bin" ]; then
            export PATH="$HOME/.goose/bin:$PATH"
        fi
    fi
    
    # Install Repomix globally using npm
    if [ "$CONFIG_ONLY" = false ]; then
        if ! npm list -g repomix &>/dev/null; then
            log "info" "Installing Repomix globally with NPM..."
            npm install -g repomix || log "warn" "Failed to install Repomix globally"
        fi

        # Verify Repomix installation
        if npm list -g repomix &>/dev/null; then
            log "success" "Repomix is installed globally"
        else
            log "warn" "Repomix installation failed. Please install manually with 'npm install -g repomix'"
        fi
        
        # Install Task Master AI globally using npm
        if ! npm list -g task-master-ai &>/dev/null; then
            log "info" "Installing Task Master AI globally with NPM..."
            npm install -g task-master-ai || log "warn" "Failed to install Task Master AI globally"
        fi
    fi
    
    # Set up Repomix global configuration
    log "info" "Setting up Repomix global configuration..."
    mkdir -p "$HOME/.config/repomix" 2>/dev/null || true
    if [ ! -f "$HOME/.config/repomix/repomix.config.json" ]; then
        if [ -f "$CONFIG_DIR/ai/repomix.config.json" ]; then
            cp "$CONFIG_DIR/ai/repomix.config.json" "$HOME/.config/repomix/repomix.config.json" || log "warn" "Failed to copy Repomix configuration"
            log "success" "Created global Repomix configuration"
        else
            log "warn" "Repomix configuration template not found"
        fi
    else
        log "info" "Repomix global configuration already exists, not overwriting"
    fi
    
    # Enable MCP server in Claude Desktop and VS Code (if available)
    setup_repomix_mcp
    
    # Set up AI tool configuration files
    setup_ai_configurations
}

# Set up Repomix MCP configuration
setup_repomix_mcp() {
    log "info" "Setting up Repomix MCP configuration..."
    
    # Setup for Cline (VS Code extension)
    mkdir -p "$HOME/.config/cline" 2>/dev/null || true
    if [ ! -f "$HOME/.config/cline/cline_mcp_settings.json" ]; then
        log "info" "Setting up Repomix MCP for Cline (VS Code extension)..."
        cat > "$HOME/.config/cline/cline_mcp_settings.json" << EOF
{
  "mcpServers": {
    "repomix": {
      "command": "npx",
      "args": [
        "-y",
        "repomix",
        "--mcp"
      ]
    }
  }
}
EOF
        log "success" "Created Cline MCP configuration for Repomix"
    else
        # Check if Cline config already has Repomix MCP configured
        if ! grep -q "repomix" "$HOME/.config/cline/cline_mcp_settings.json"; then
            log "info" "Updating existing Cline MCP configuration..."
            # This is a simple backup and replace, consider using jq for more complex scenarios
            cp "$HOME/.config/cline/cline_mcp_settings.json" "$HOME/.config/cline/cline_mcp_settings.json.bak"
            cat > "$HOME/.config/cline/cline_mcp_settings.json" << EOF
{
  "mcpServers": {
    "repomix": {
      "command": "npx",
      "args": [
        "-y",
        "repomix",
        "--mcp"
      ]
    }
  }
}
EOF
            log "success" "Updated Cline MCP configuration for Repomix"
        else
            log "info" "Repomix MCP already configured for Cline"
        fi
    fi
    
    # Setup for Claude Desktop (if installed)
    local claude_config_dir="$HOME/Library/Application Support/Claude Desktop"
    if [ -d "$claude_config_dir" ]; then
        log "info" "Claude Desktop detected, setting up MCP configuration..."
        if [ ! -f "$claude_config_dir/claude_desktop_config.json" ]; then
            cat > "$claude_config_dir/claude_desktop_config.json" << EOF
{
  "mcpServers": {
    "repomix": {
      "command": "npx",
      "args": [
        "-y",
        "repomix",
        "--mcp"
      ]
    }
  }
}
EOF
            log "success" "Created Claude Desktop MCP configuration for Repomix"
        else
            # Check if Claude config already has Repomix MCP configured
            if ! grep -q "repomix" "$claude_config_dir/claude_desktop_config.json"; then
                log "info" "Updating existing Claude Desktop MCP configuration..."
                cp "$claude_config_dir/claude_desktop_config.json" "$claude_config_dir/claude_desktop_config.json.bak"
                cat > "$claude_config_dir/claude_desktop_config.json" << EOF
{
  "mcpServers": {
    "repomix": {
      "command": "npx",
      "args": [
        "-y",
        "repomix",
        "--mcp"
      ]
    }
  }
}
EOF
                log "success" "Updated Claude Desktop MCP configuration for Repomix"
            else
                log "info" "Repomix MCP already configured for Claude Desktop"
            fi
        fi
    else
        log "info" "Claude Desktop not found, skipping MCP configuration"
    fi
    
    # Setup LaunchAgent for automatic startup
    log "info" "Setting up autostart for Repomix MCP server..."
    
    # Create log directory
    mkdir -p "$HOME/.repomix/logs" 2>/dev/null || true
    
    # Check for existing Launch Agent
    local launch_agents_dir="$HOME/Library/LaunchAgents"
    mkdir -p "$launch_agents_dir" 2>/dev/null || true
    
    if [ -f "$CONFIG_DIR/ai/com.repomix.mcp.plist" ]; then
        # Replace path placeholders with actual paths
        local node_path="$(which node || echo '/usr/local/bin/node')"
        local npx_path="$(which npx || echo '/usr/local/bin/npx')"
        local temp_plist="/tmp/com.repomix.mcp.plist.tmp"
        
        # Read template and substitute paths
        cat "$CONFIG_DIR/ai/com.repomix.mcp.plist" | \
            sed "s|/usr/local/bin/node|$node_path|g" | \
            sed "s|/usr/local/bin/npx|$npx_path|g" > "$temp_plist"
        
        # Copy modified plist to LaunchAgents
        cp "$temp_plist" "$launch_agents_dir/com.repomix.mcp.plist"
        rm "$temp_plist"
        
        # Check if LaunchAgent is already loaded
        if launchctl list 2>/dev/null | grep -q "com.repomix.mcp"; then
            log "info" "Unloading existing Repomix MCP LaunchAgent..."
            { launchctl unload "$launch_agents_dir/com.repomix.mcp.plist" 2>/dev/null || true; } &>/dev/null
            # Small delay to ensure proper unloading before reloading
            sleep 1
        fi
        
        # Load the LaunchAgent
        log "info" "Loading Repomix MCP LaunchAgent..."
        { launchctl load "$launch_agents_dir/com.repomix.mcp.plist" 2>/dev/null || log "warn" "Failed to load Repomix MCP LaunchAgent"; } 2>/dev/null
        
        log "success" "Repomix MCP server will now start automatically at login"
        log "info" "To manually control the service:"
        log "info" "  Start: launchctl load ~/Library/LaunchAgents/com.repomix.mcp.plist"
        log "info" "  Stop: launchctl unload ~/Library/LaunchAgents/com.repomix.mcp.plist"
    else
        log "warn" "Repomix MCP LaunchAgent template not found, skipping autostart setup"
        log "info" "You can still manually start the MCP server with 'repomix-mcp'"
    fi
}

# Set up AI configuration files
setup_ai_configurations() {
    log "info" "Setting up AI tool configuration files..."
    
    # Prepare directories
    AI_CONFIG_DIR="$DOTFILES_DIR/config/ai"
    LOCAL_AI_CONFIG_DIR="$LOCAL_CONFIG_DIR/ai"
    
    # Determine which templates to use based on environment
    local template_suffix=""
    if [ "$PROFILE" = "work" ]; then
        template_suffix=".work"
        log "info" "Using work environment configuration for AI tools"
    else
        template_suffix=".personal"
        log "info" "Using personal environment configuration for AI tools"
    fi
    
    # Set up Aider configuration
    if [ ! -f "$LOCAL_AI_CONFIG_DIR/aider.conf.yml" ]; then
        log "info" "Creating Aider configuration..."
        if [ -f "$AI_CONFIG_DIR/aider.conf.yml$template_suffix" ]; then
            mkdir -p "$LOCAL_AI_CONFIG_DIR" 2>/dev/null || true
            cp "$AI_CONFIG_DIR/aider.conf.yml$template_suffix" "$LOCAL_AI_CONFIG_DIR/aider.conf.yml"
            log "success" "Created Aider configuration from template"
        else
            log "warn" "Aider configuration template not found"
            # Create a minimal configuration
            mkdir -p "$LOCAL_AI_CONFIG_DIR" 2>/dev/null || true
            cat > "$LOCAL_AI_CONFIG_DIR/aider.conf.yml" << EOF
# Aider Configuration
alias:
  - "fast:gpt-4o-mini"
  - "smart:gpt-4o"
  - "opus:claude-3-opus-20240229"
  - "sonnet:claude-3-sonnet-20240229"
EOF
            log "info" "Created minimal Aider configuration"
        fi
        
        # Link configuration to home directory
        link_file "$LOCAL_AI_CONFIG_DIR/aider.conf.yml" "$HOME/.aider.conf.yml" "$BACKUP_DIR"
    else
        log "info" "Aider configuration already exists, not overwriting"
        # Ensure symlink exists
        link_file "$LOCAL_AI_CONFIG_DIR/aider.conf.yml" "$HOME/.aider.conf.yml" "$BACKUP_DIR"
    fi
    
    # Set up Aider .env file if needed
    if [ ! -f "$LOCAL_AI_CONFIG_DIR/.env" ]; then
        log "info" "Creating Aider .env file..."
        if [ -f "$AI_CONFIG_DIR/aider.env$template_suffix" ]; then
            cp "$AI_CONFIG_DIR/aider.env$template_suffix" "$LOCAL_AI_CONFIG_DIR/.env"
            log "success" "Created Aider .env file from template"
        else
            log "warn" "Aider .env template not found"
            # Create a minimal .env file
            cat > "$LOCAL_AI_CONFIG_DIR/.env" << EOF
# Aider API Keys - Update with your actual keys
OPENAI_API_KEY=
ANTHROPIC_API_KEY=

# Editor configuration
AIDER_EDITOR=cursor --wait
EOF
            log "info" "Created minimal Aider .env file"
        fi
        
        # Link .env to home directory
        link_file "$LOCAL_AI_CONFIG_DIR/.env" "$HOME/.env" "$BACKUP_DIR"
    else
        log "info" "Aider .env file already exists, not overwriting"
        # Ensure symlink exists
        link_file "$LOCAL_AI_CONFIG_DIR/.env" "$HOME/.env" "$BACKUP_DIR"
    fi
    
    # Remind to update API keys
    log "info" "Remember to update your API keys in config/local/.zshrc.local and config/local/ai/.env"
}

# Link configuration files
link_configuration_files() {
    log "info" "Linking configuration files..."
    
    # Create necessary directories
    mkdir -p "$HOME/.config/starship"
    mkdir -p "$HOME/.config/goose"
    mkdir -p "$HOME/.config/dotfiles"
    mkdir -p "$LOCAL_CONFIG_DIR"

    # Link core dotfiles
    link_file "$CONFIG_DIR/.zshrc" "$HOME/.zshrc" "$BACKUP_DIR"
    link_file "$CONFIG_DIR/.gitconfig" "$HOME/.gitconfig" "$BACKUP_DIR"
    link_file "$CONFIG_DIR/.gitignore_global" "$HOME/.gitignore_global" "$BACKUP_DIR"
    link_file "$CONFIG_DIR/starship.toml" "$HOME/.config/starship/starship.toml" "$BACKUP_DIR"
    
    # Link profile-specific configurations
    log "info" "Applying profile-specific configurations for: $PROFILE"
    
    # Check for profile-specific Goose configuration
    local goose_template_path="$CONFIG_DIR/templates/$PROFILE/goose/config.yaml"
    log "info" "Checking for profile-specific Goose config at: $goose_template_path"
    
    if [ -f "$goose_template_path" ]; then
        log "info" "Using profile-specific Goose configuration for $PROFILE"
        link_file "$goose_template_path" "$HOME/.config/goose/config.yaml" "$BACKUP_DIR"
    else
        # Use default Goose configuration
        log "info" "Profile-specific Goose config not found at $goose_template_path"
        log "info" "Using default configuration instead. To create profile-specific configs:"
        log "info" "  1. Create directory: mkdir -p $CONFIG_DIR/templates/$PROFILE/goose"
        log "info" "  2. Copy default: cp $CONFIG_DIR/goose/config.yaml $CONFIG_DIR/templates/$PROFILE/goose/"
        log "info" "  3. Edit the config to use your preferred model (e.g., gpt-4o)"
        link_file "$CONFIG_DIR/goose/config.yaml" "$HOME/.config/goose/config.yaml" "$BACKUP_DIR"
    fi
    
    # Set up machine-specific configuration files
    setup_local_config
}

# Set up machine-specific configuration files
setup_local_config() {
    log "info" "Setting up machine-specific configuration..."
    
    # Check if we should migrate existing .zshrc.local from home directory
    if [ -f "$HOME/.zshrc.local" ] && [ ! -L "$HOME/.zshrc.local" ] && [ ! -f "$LOCAL_CONFIG_DIR/.zshrc.local" ]; then
        log "info" "Found existing .zshrc.local in home directory, migrating to dotfiles repo..."
        cp "$HOME/.zshrc.local" "$LOCAL_CONFIG_DIR/.zshrc.local" || log "warn" "Failed to migrate ~/.zshrc.local"
        mv "$HOME/.zshrc.local" "$BACKUP_DIR/.zshrc.local.bak" || log "warn" "Failed to backup ~/.zshrc.local" 
        log "success" "Migrated ~/.zshrc.local to the dotfiles repo"
    fi
    
    # Create .zshrc.local in the local config directory if it doesn't exist
    local zshrc_local_file="$LOCAL_CONFIG_DIR/.zshrc.local"
    if [ ! -f "$zshrc_local_file" ]; then
        log "info" "Creating machine-specific zsh config from template..."
        cp "$CONFIG_DIR/.zshrc.local.template" "$zshrc_local_file" || log "warn" "Failed to create $zshrc_local_file"
        
        # Update environment type based on profile
        if [ "$PROFILE" = "work" ]; then
            log "info" "Configuring for work environment"
            sed -i '' 's/# ENVIRONMENT_TYPE="personal"/# ENVIRONMENT_TYPE="personal"/' "$zshrc_local_file"
            sed -i '' 's/# ENVIRONMENT_TYPE="work"/ENVIRONMENT_TYPE="work"/' "$zshrc_local_file"
        else
            log "info" "Configuring for personal environment"
            sed -i '' 's/# ENVIRONMENT_TYPE="personal"/ENVIRONMENT_TYPE="personal"/' "$zshrc_local_file"
            sed -i '' 's/# ENVIRONMENT_TYPE="work"/# ENVIRONMENT_TYPE="work"/' "$zshrc_local_file"
        fi
        
        # Add dotfiles bin to PATH if not already there
        echo "" >> "$zshrc_local_file"
        echo "# Add dotfiles bin to PATH" >> "$zshrc_local_file"
        echo "export PATH=\"\$HOME/Projects/dotfiles/bin:\$PATH\"" >> "$zshrc_local_file"
        
        log "info" "Created $zshrc_local_file - remember to add your API keys!"
    else
        log "info" "Machine-specific zsh config already exists, not overwriting"
        
        # Add dotfiles bin to PATH if not already there
        if ! grep -q "export PATH.*dotfiles/bin" "$zshrc_local_file"; then
            log "info" "Adding dotfiles bin to PATH in .zshrc.local"
            echo "" >> "$zshrc_local_file"
            echo "# Add dotfiles bin to PATH" >> "$zshrc_local_file"
            echo "export PATH=\"\$HOME/Projects/dotfiles/bin:\$PATH\"" >> "$zshrc_local_file"
        fi
    fi
    
    # Link the machine-specific config to home directory for zsh to source it
    link_file "$zshrc_local_file" "$HOME/.zshrc.local" "$BACKUP_DIR"
    
    log "success" "Machine-specific configuration setup complete"
}

# Configure macOS defaults
configure_macos() {
    log "info" "Configuring macOS defaults..."
    source "$DOTFILES_DIR/scripts/macos.sh" || log "warn" "Failed to configure some macOS settings"
}

# Check for conflicting environment variables
check_conflicting_env_vars() {
    log "info" "Checking for conflicting environment variables..."
    
    local zshrc_local="$HOME/.zshrc.local"
    if [ -f "$zshrc_local" ]; then
        # Check for Goose environment variables that would override config files
        if grep -q "export GOOSE_MODEL=" "$zshrc_local" || grep -q "export GOOSE_PROVIDER=" "$zshrc_local"; then
            log "warn" "Found Goose environment variables in $zshrc_local that will override profile configurations"
            log "warn" "Consider removing these lines to allow profile-specific configurations to work:"
            
            grep "export GOOSE_MODEL=" "$zshrc_local" 2>/dev/null || true
            grep "export GOOSE_PROVIDER=" "$zshrc_local" 2>/dev/null || true
            
            log "info" "Goose settings are better managed through the profile system:"
            log "info" "  ~/Projects/dotfiles/config/templates/<profile>/goose/config.yaml"
            
            # Ask if user wants to automatically remove these lines
            printf "Would you like to automatically remove these variables from .zshrc.local? (y/n) "
            read answer
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                # Create backup
                cp "$zshrc_local" "$zshrc_local.bak"
                log "info" "Created backup at $zshrc_local.bak"
                
                # Remove the lines
                sed -i '' '/export GOOSE_MODEL=/d' "$zshrc_local"
                sed -i '' '/export GOOSE_PROVIDER=/d' "$zshrc_local"
                
                # Add comment explaining the removal
                echo "" >> "$zshrc_local"
                echo "# Goose settings are now managed by the profile system through config files" >> "$zshrc_local"
                echo "# To change settings, update the appropriate profile config in:" >> "$zshrc_local"
                echo "# ~/Projects/dotfiles/config/templates/<profile>/goose/config.yaml" >> "$zshrc_local"
                echo "# and run: ./install.sh --profile=<profile>" >> "$zshrc_local"
                
                log "success" "Removed conflicting Goose environment variables from $zshrc_local"
            else
                log "warn" "Keeping conflicting environment variables. Profile configurations may not work as expected."
            fi
        else
            log "success" "No conflicting environment variables found"
        fi
    fi
}

# Verify installation
verify_installation() {
    log "info" "Verifying installation..."
    local issues=0
    
    # Update PATH to include potential locations for installed tools
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/.goose/bin:$PATH"
    export PATH="$DOTFILES_DIR/bin:$PATH"  # Add dotfiles bin directory to PATH
    
    # Check core tools
    for cmd in brew git python3; do
        if ! command -v $cmd &>/dev/null; then
            log "warn" "$cmd not found in PATH"
            issues=$((issues+1))
        else
            log "success" "$cmd is available: $($cmd --version | head -n1)"
        fi
    done
    
    # Check UV installation
    if command -v uv &>/dev/null; then
        log "success" "UV is available: $(uv --version)"
        
        # Quick test of UV functionality
        log "info" "Testing UV functionality..."
        TEST_DIR=$(mktemp -d)
        if uv venv "$TEST_DIR/test-venv" &>/dev/null; then
            log "success" "UV can create virtual environments"
            rm -rf "$TEST_DIR"
        else
            log "warn" "UV virtual environment test failed"
            issues=$((issues+1))
        fi
    else
        log "warn" "UV not found in PATH"
        issues=$((issues+1))
    fi
    
    # Check AI tools
    for cmd in aider goose; do
        if ! command -v $cmd &>/dev/null; then
            log "warn" "$cmd not found in PATH. Check installation or restart your terminal"
            issues=$((issues+1))
        else
            log "success" "$cmd is available"
        fi
    done
    
    # Check if repomix is available globally or via npx
    if npm list -g repomix &>/dev/null; then
        log "success" "Repomix is available globally"
    elif command -v npx &>/dev/null && npx --no-install repomix --version &>/dev/null; then
        log "success" "Repomix is available via npx"
    else
        log "warn" "Repomix may not be available. Check Node.js installation"
        issues=$((issues+1))
    fi
    
    # Check profile
    log "info" "Current profile: $PROFILE"
    
    # Summary
    if [ $issues -eq 0 ]; then
        log "success" "All core components verified successfully!"
    else
        log "warn" "Found $issues issues with the installation"
        log "info" "You may need to restart your terminal or run 'source ~/.zshrc' to complete the setup"
    fi
}

# Main installation flow
main() {
    log "info" "Starting dotfiles installation with profile: $PROFILE"
    
    # Show mode information
    if [ "$QUICK_MODE" = true ]; then
        log "info" "Running in quick mode - will skip all Homebrew operations and installations that are already complete"
    fi
    
    if [ "$CONFIG_ONLY" = true ]; then
        log "info" "Running in config-only mode - will only perform symlinks and configuration, no installations"
    fi
    
    if [ "$PROFILE" = "work" ]; then
        log "info" "Configuring for work environment"
    else
        log "info" "Configuring for personal environment"
    fi
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    log "info" "Backup directory created at $BACKUP_DIR"
    
    if [ "$CONFIG_ONLY" = false ]; then
        # Critical foundation components
        check_system_requirements
        setup_homebrew || critical_error "Homebrew setup failed"
        install_core_tools || critical_error "Core tools installation failed"
        
        # Setup tools (less critical, can proceed with warnings)
        setup_uv          # Python packaging
        setup_shell       # Zsh configuration
        
        # Applications (optional based on flags)
        install_applications
        
        # AI development tools (depends on Python/UV)
        setup_ai_tools
    else
        log "info" "Skipping all installation steps due to --config-only flag"
    fi
    
    # Configuration (final step)
    link_configuration_files
    configure_macos
    
    # Update PATH variables for verification
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/.goose/bin:$PATH"
    
    # Check for conflicting environment variables
    check_conflicting_env_vars
    
    # Verify installation only if not in config-only mode
    if [ "$CONFIG_ONLY" = false ]; then
        verify_installation
    fi
    
    # Print summary
    log "success" "Installation complete! 🎉"
    log "info" "Configuration summary:"
    log "info" "  • Environment: $([ "$PROFILE" = "work" ] && echo "Work" || echo "Personal")"
    log "info" "  • Profile: $PROFILE"
    log "info" "  • Config only: $([ "$CONFIG_ONLY" = true ] && echo "Enabled (only symlinks and configuration)" || echo "Disabled")"
    log "info" "  • Quick mode: $([ "$QUICK_MODE" = true ] && echo "Enabled (skipped Homebrew operations)" || echo "Disabled")"
    log "info" "  • App installation: $([ "$SKIP_APPS" = true ] || [ "$CONFIG_ONLY" = true ] && echo "Skipped" || echo "Performed")"
    log "info" "  • Backup directory: $BACKUP_DIR"
    
    # Skip AI tools summary in config-only mode
    if [ "$CONFIG_ONLY" = false ]; then
        # AI tools summary
        log "info" "AI tools:"
        if command -v aider &>/dev/null; then
            log "success" "  • Aider: Installed and available ($(aider --version 2>/dev/null || echo 'unknown version'))"
        else 
            log "warn" "  • Aider: Not found in PATH"
            log "info" "    Run 'source ~/.zshrc' or restart your terminal to access Aider"
        fi
        
        if command -v goose &>/dev/null; then
            log "success" "  • Goose: Installed and available"
        elif [ -f "$HOME/.goose/bin/goose" ]; then
            log "warn" "  • Goose: Installed but not in PATH"
            log "info" "    Run 'source ~/.zshrc' or restart your terminal to access Goose"
        else
            log "warn" "  • Goose: Not installed or not found"
        fi
    fi
    
    # Configuration files
    log "info" "Configuration files:"
    [ -f "$LOCAL_CONFIG_DIR/.zshrc.local" ] && log "success" "  • Machine-specific: Created at $LOCAL_CONFIG_DIR/.zshrc.local" || log "warn" "  • Machine-specific: Not found"
    [ -f "$HOME/.zshrc.local" ] && log "success" "  • Linked to: $HOME/.zshrc.local" || log "warn" "  • Link missing: ~/.zshrc.local"
    
    # Automatically source zshrc if possible
    log "info" "Applying changes by sourcing ~/.zshrc..."
    if [[ -n "$ZSH_VERSION" ]]; then
        # Running in zsh, can source directly
        source "$HOME/.zshrc" || log "warn" "Could not source ~/.zshrc"
        log "success" "Applied changes to current shell. All tools should be available now."
    else
        # Not running in zsh
        log "warn" "Not running in zsh. Please restart your terminal or run 'source ~/.zshrc' manually."
    fi
}

# Run the main installation process
main