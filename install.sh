#!/usr/bin/env bash
# Dotfiles installation script

set -e

DOTFILES_DIR="$HOME/dotfiles"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only."
    exit 1
fi

print_header "Installing Dotfiles"

# Check if we're in the dotfiles directory
if [[ ! -d "$DOTFILES_DIR" ]]; then
    print_error "Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR"

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
    print_header "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    print_status "Homebrew already installed"
fi

# Install packages from Brewfile
if [[ -f "Brewfile" ]]; then
    print_header "Installing packages from Brewfile..."
    brew bundle --verbose
else
    print_warning "No Brewfile found, skipping package installation"
fi

# Set up fzf
print_header "Setting up fzf shell integration..."
if command -v fzf &> /dev/null; then
    /opt/homebrew/opt/fzf/install --all --no-bash --no-fish
else
    print_warning "fzf not found, skipping shell integration setup"
fi

# Initialize atuin
print_header "Initializing atuin..."
if command -v atuin &> /dev/null; then
    atuin import auto || print_warning "Could not import shell history to atuin"
else
    print_warning "atuin not found, skipping initialization"
fi

# Initialize zoxide
print_header "Initializing zoxide..."
if command -v zoxide &> /dev/null; then
    print_status "zoxide installed successfully"
else
    print_warning "zoxide not found"
fi

# Create symlinks
print_header "Creating configuration symlinks..."
if [[ -x "scripts/symlink.sh" ]]; then
    ./scripts/symlink.sh
else
    print_error "Symlink script not found or not executable"
    exit 1
fi

# Update Ghostty config to use Catppuccin
print_header "Updating Ghostty configuration..."
if [[ -f "$HOME/.config/ghostty/config" ]]; then
    # Replace the theme line with Catppuccin
    if grep -q "theme.*Gruvbox" "$HOME/.config/ghostty/config"; then
        sed -i '' 's/theme = Gruvbox Dark/theme = catppuccin-mocha/' "$HOME/.config/ghostty/config"
        print_status "Updated Ghostty theme to Catppuccin Mocha"
    fi
fi

print_header "Installation Complete!"
print_status "Please restart your terminal or run: source ~/.zshrc"
print_status ""
print_status "New commands available:"
print_status "  z <directory>    # Jump to directory (zoxide)"
print_status "  eza --tree       # Better ls with tree view"
print_status "  fzf              # Fuzzy file finder"
print_status "  atuin search     # Search shell history"
print_status "  ct <question>    # Claude terminal helper"
print_status "  ce <task>        # Claude enablement helper"
print_status ""
print_status "Terminal features:"
print_status "  - VI mode enabled (press Esc for normal mode)"
print_status "  - Starship prompt with git status"
print_status "  - Catppuccin color scheme"
print_status "  - Smart completions with carapace"