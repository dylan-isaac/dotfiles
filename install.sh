#!/bin/zsh

# Set script to exit on error
set -e

DOTFILES_DIR="$HOME/Projects/dotfiles"
CONFIG_DIR="$DOTFILES_DIR/config"
BACKUP_DIR="$HOME/.dotfiles.backup.$(date +%Y%m%d_%H%M%S)"
SKIP_APPS=false

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
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || critical_error "Failed to install Homebrew"
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
    
    # If Python is available, try pip installation (preferred method)
    if command -v python3 &>/dev/null; then
        log "info" "Installing UV via pip..."
        python3 -m pip install --user uv
        
        # Check if installation succeeded
        if command -v uv &>/dev/null || [ -f "$HOME/.local/bin/uv" ]; then
            export PATH="$HOME/.local/bin:$PATH"  # Add to PATH for immediate use
            log "success" "UV installed successfully via pip"
            return 0
        else
            log "warn" "Failed to install UV via pip, trying cargo method..."
        fi
    fi
    
    # Try cargo installation method
    log "info" "Installing Rust (required for UV)..."
    if ! command -v rustup &>/dev/null; then
        brew install rustup || log "warn" "Failed to install rustup"
        rustup-init -y --no-modify-path || log "warn" "Failed to initialize rustup"
    fi
    
    # Source cargo env if it exists
    [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
    
    # Check if cargo is available
    if command -v cargo &>/dev/null; then
        log "info" "Installing UV via Cargo..."
        cargo install uv || log "warn" "Failed to install UV via Cargo"
        
        # Add cargo bin to PATH for immediate use
        export PATH="$HOME/.cargo/bin:$PATH"
    else
        log "warn" "Cargo not found, cannot install UV via Cargo"
    fi
    
    # Final verification
    if command -v uv &>/dev/null; then
        log "success" "UV installed successfully"
        return 0
    else
        log "warn" "Failed to install UV. Some Python functionality will be limited."
        return 1
    fi
}

# Install additional applications via Homebrew
install_applications() {
    if [ "$SKIP_APPS" = false ]; then
        log "info" "Installing applications..."
        
        # Remove conflicting applications first
        log "info" "Removing potentially conflicting applications..."
        brew uninstall --cask docker balenaetcher calibre --force 2>/dev/null || true

        # Install essential packages
        log "info" "Installing essential packages..."
        brew bundle --file="$DOTFILES_DIR/Brewfile" || log "warn" "Some applications failed to install"
    else
        log "info" "Skipping application installation (--skip-apps flag provided)"
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
}

# Set up AI development tools
setup_ai_tools() {
    log "info" "Setting up AI development tools..."
    
    # Install Aider (requires Python/UV)
    log "info" "Installing Aider..."
    if command -v uv &>/dev/null; then
        # Create a temporary venv for installation
        TEMP_VENV=$(mktemp -d)/aider-venv
        log "info" "Creating temporary environment for Aider installation..."
        uv venv "$TEMP_VENV" && source "$TEMP_VENV/bin/activate"
        
        # Install with UV if possible
        uv pip install aider-chat && log "success" "Aider installed successfully with UV"
        
        # Clean up
        deactivate
        rm -rf "$TEMP_VENV"
    else
        # Fallback to pip
        log "info" "Installing Aider with pip (UV not available)..."
        python3 -m pip install aider-chat && log "success" "Aider installed successfully with pip"
    fi
    
    # Install Goose (if needed in the future)
    # This section can be expanded when Goose setup is needed
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
    
    log "success" "Installation complete! Please restart your terminal."
}

# Run the main installation process
main