#!/bin/zsh

# Set script to exit on error
set -e

DOTFILES_DIR="$HOME/Projects/dotfiles"
CONFIG_DIR="$DOTFILES_DIR/config"
BACKUP_DIR="$HOME/.dotfiles.backup.$(date +%Y%m%d_%H%M%S)"
SKIP_APPS=false
QUICK_MODE=false
WORK_ENV=false

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
        --work) WORK_ENV=true ;;
        --help) 
            echo "Usage: ./install.sh [options]"
            echo "Options:"
            echo "  --skip-apps       Skip installation of applications"
            echo "  --quick           Skip installations that are already complete"
            echo "  --work            Configure for work environment (different AI settings)"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *) echo -e "${RED}Unknown parameter: $1${NC}"; exit 1 ;;
    esac
    shift
done

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
    
    # Install Homebrew if not installed
    if ! command -v brew &>/dev/null; then
        log "info" "Installing Homebrew..."
        /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || critical_error "Failed to install Homebrew"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        log "success" "Homebrew is already installed"
    fi

    # Update Homebrew
    log "info" "Updating Homebrew..."
    brew update || log "warn" "Failed to update Homebrew, continuing anyway"
}

# Install core development tools
install_core_tools() {
    log "info" "Installing core development tools..."
    
    # Install Git (required for remaining steps)
    if ! command -v git &>/dev/null; then
        log "info" "Installing Git..."
        brew install git || critical_error "Failed to install Git"
    else
        log "success" "Git is already installed"
    fi
    
    # Install Python
    if ! command -v python3 &>/dev/null; then
        log "info" "Installing Python..."
        brew install python || critical_error "Failed to install Python"
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
}

# Set up UV package manager
setup_uv() {
    log "info" "Setting up UV package manager..."
    
    # First check if UV is already installed
    if command -v uv &>/dev/null; then
        log "success" "UV is already installed: $(uv --version)"
        return 0
    fi
    
    # If Python is available, install via pip (preferred method)
    if command -v python3 &>/dev/null; then
        log "info" "Installing UV via pip..."
        python3 -m pip install --user uv
        
        # Check if installation succeeded
        if command -v uv &>/dev/null || [ -f "$HOME/.local/bin/uv" ]; then
            export PATH="$HOME/.local/bin:$PATH"  # Add to PATH for immediate use
            log "success" "UV installed successfully via pip"
            return 0
        else
            log "warn" "Failed to install UV via pip"
        fi
    else
        log "warn" "Python not found. UV installation requires Python."
    fi
    
    log "warn" "Failed to install UV. Some Python functionality will be limited."
    return 1
}

# Install additional applications via Homebrew
install_applications() {
    if [ "$SKIP_APPS" = true ]; then
        log "info" "Skipping application installation (--skip-apps flag provided)"
        return 0
    fi
    
    log "info" "Checking application installations..."
    
    # Quick mode skips Brewfile installation if core tools are already installed
    if [ "$QUICK_MODE" = true ]; then
        # Check for essential tools as indicators that apps are installed
        local missing_tools=0
        local core_tools=("bat" "eza" "fzf" "ripgrep" "zoxide" "starship" "gh")
        
        for tool in "${core_tools[@]}"; do
            if ! command -v "$tool" &>/dev/null; then
                log "info" "Core tool '$tool' is missing"
                missing_tools=$((missing_tools+1))
            fi
        done
        
        if [ $missing_tools -eq 0 ]; then
            log "success" "All core tools are already installed. Skipping Brewfile installation."
            return 0
        else
            log "info" "Found $missing_tools missing core tools. Will install applications."
        fi
    fi
    
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
    log "info" "Installing packages from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile" || log "warn" "Some applications failed to install"
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
}

# Set up AI development tools
setup_ai_tools() {
    log "info" "Setting up AI development tools..."
    
    # Check if gcc/gfortran is installed for Aider (needed for scipy)
    if ! command -v gfortran &>/dev/null; then
        log "info" "Installing gcc (includes gfortran) for Aider dependencies..."
        brew install gcc || log "warn" "Failed to install gcc. Aider installation might fail."
    fi
    
    # Check if AI tools should be skipped in quick mode
    if [ "$QUICK_MODE" = true ]; then
        # Check if both tools are available
        local aider_installed=false
        local goose_installed=false
        
        if command -v aider &>/dev/null; then
            log "success" "Aider is already installed: $(aider --version 2>/dev/null || echo 'unknown version')"
            aider_installed=true
        fi
        
        if command -v goose &>/dev/null || [ -f "$HOME/.goose/bin/goose" ]; then
            log "success" "Goose is already installed"
            goose_installed=true
            
            # Ensure Goose is in PATH for this session
            if [ -d "$HOME/.goose/bin" ]; then
                export PATH="$HOME/.goose/bin:$PATH"
            fi
        fi
        
        # If both are installed, skip the rest
        if $aider_installed && $goose_installed; then
            log "success" "All AI tools are already installed. Skipping installation."
            return 0
        else
            log "info" "Some AI tools are missing. Will proceed with installation."
        fi
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
        export PATH="$HOME/.goose/bin:$PATH"
        
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
    
    # Set up AI tool configuration files
    setup_ai_configurations
}

# Set up AI configuration files
setup_ai_configurations() {
    log "info" "Setting up AI tool configuration files..."
    
    # Create AI config directory if it doesn't exist
    mkdir -p "$HOME/.config/aider" 2>/dev/null || true
    mkdir -p "$HOME/.config/goose" 2>/dev/null || true
    
    # Create base directories for config files
    AI_CONFIG_DIR="$DOTFILES_DIR/config/ai"
    
    # Determine which templates to use based on environment
    local template_suffix=""
    if [ "$WORK_ENV" = true ]; then
        template_suffix=".work"
        log "info" "Using work environment configuration for AI tools"
    else
        template_suffix=".personal"
        log "info" "Using personal environment configuration for AI tools"
    fi
    
    # Set up Aider configuration
    if [ ! -f "$HOME/.aider.conf.yml" ]; then
        log "info" "Creating Aider configuration..."
        if [ -f "$AI_CONFIG_DIR/aider.conf.yml$template_suffix" ]; then
            cp "$AI_CONFIG_DIR/aider.conf.yml$template_suffix" "$HOME/.aider.conf.yml"
            log "success" "Created Aider configuration from template"
        else
            log "warn" "Aider configuration template not found"
            # Create a minimal configuration
            cat > "$HOME/.aider.conf.yml" << EOF
# Aider Configuration
alias:
  - "fast:gpt-4o-mini"
  - "smart:gpt-4o"
  - "opus:claude-3-opus-20240229"
  - "sonnet:claude-3-sonnet-20240229"
EOF
            log "info" "Created minimal Aider configuration"
        fi
    else
        log "info" "Aider configuration already exists, not overwriting"
    fi
    
    # Set up Aider .env file if needed
    if [ ! -f "$HOME/.env" ]; then
        log "info" "Creating Aider .env file..."
        if [ -f "$AI_CONFIG_DIR/aider.env$template_suffix" ]; then
            cp "$AI_CONFIG_DIR/aider.env$template_suffix" "$HOME/.env"
            log "success" "Created Aider .env file from template"
        else
            log "warn" "Aider .env template not found"
            # Create a minimal .env file
            cat > "$HOME/.env" << EOF
# Aider API Keys - Update with your actual keys
OPENAI_API_KEY=
ANTHROPIC_API_KEY=

# Editor configuration
AIDER_EDITOR=cursor --wait
EOF
            log "info" "Created minimal Aider .env file"
        fi
    else
        log "info" "Aider .env file already exists, not overwriting"
    fi
    
    # Remind to update API keys
    log "info" "Remember to update your API keys in .zshrc.local and ~/.env"
}

# Link configuration files
link_configuration_files() {
    log "info" "Linking configuration files..."
    
    # Create necessary directories
    mkdir -p "$HOME/.config/starship"

    # Link configuration files
    link_file "$CONFIG_DIR/.zshrc" "$HOME/.zshrc" "$BACKUP_DIR"
    link_file "$CONFIG_DIR/.gitconfig" "$HOME/.gitconfig" "$BACKUP_DIR"
    link_file "$CONFIG_DIR/.gitignore_global" "$HOME/.gitignore_global" "$BACKUP_DIR"
    
    # Create .zshrc.local from template if it doesn't exist
    if [ ! -f "$HOME/.zshrc.local" ]; then
        log "info" "Creating .zshrc.local from template..."
        cp "$CONFIG_DIR/.zshrc.local.template" "$HOME/.zshrc.local" || log "warn" "Failed to create .zshrc.local"
        log "info" "Created .zshrc.local - remember to add your API keys!"
    else
        log "info" ".zshrc.local already exists, not overwriting"
    fi
}

# Configure macOS defaults
configure_macos() {
    log "info" "Configuring macOS defaults..."
    source "$DOTFILES_DIR/scripts/macos.sh" || log "warn" "Failed to configure some macOS settings"
}

# Verify installation
verify_installation() {
    log "info" "Verifying installation..."
    local issues=0
    
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
    log "info" "Starting dotfiles installation..."
    
    # Show mode information
    if [ "$QUICK_MODE" = true ]; then
        log "info" "Running in quick mode - will skip installations that are already complete"
    fi
    
    if [ "$WORK_ENV" = true ]; then
        log "info" "Configuring for work environment - will use work-specific AI settings"
    else
        log "info" "Configuring for personal environment"
    fi
    
    # Critical foundation components
    check_system_requirements
    setup_homebrew
    install_core_tools
    
    # Setup tools (less critical, can proceed with warnings)
    setup_uv          # Python packaging
    setup_shell       # Zsh configuration
    
    # Applications (optional based on flags)
    install_applications
    
    # AI development tools (depends on Python/UV)
    setup_ai_tools
    
    # Configuration (final step)
    link_configuration_files
    configure_macos
    
    # Verify
    verify_installation
    
    # Print summary
    log "success" "Installation complete!"
    log "info" "Configuration summary:"
    log "info" "  • Environment: $([ "$WORK_ENV" = true ] && echo "Work" || echo "Personal")"
    log "info" "  • Quick mode: $([ "$QUICK_MODE" = true ] && echo "Enabled" || echo "Disabled")"
    log "info" "  • App installation: $([ "$SKIP_APPS" = true ] && echo "Skipped" || echo "Performed")"
    
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
    
    # Configuration files
    log "info" "Configuration files:"
    [ -f "$HOME/.aider.conf.yml" ] && log "success" "  • Aider: Configuration file created at ~/.aider.conf.yml" || log "warn" "  • Aider: No configuration file found"
    [ -f "$HOME/.env" ] && log "success" "  • Aider: Environment file created at ~/.env" || log "warn" "  • Aider: No environment file found"
    [ -f "$HOME/.zshrc.local" ] && log "success" "  • Local configuration: Created at ~/.zshrc.local" || log "warn" "  • Local configuration: Not found"
    
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