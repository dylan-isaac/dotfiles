#!/bin/bash

# Set script to exit on error
set -e

DOTFILES_DIR="$HOME/Projects/dotfiles"
CONFIG_DIR="$DOTFILES_DIR/config"
BACKUP_DIR="$HOME/.dotfiles.backup.$(date +%Y%m%d_%H%M%S)"

# Function to create symbolic links
link_file() {
    local src=$1
    local dest=$2
    local backup_dir=$3

    # If the destination file exists and is not a symlink
    if [ -f "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up $dest to $backup_dir/"
        mkdir -p "$backup_dir"
        mv "$dest" "$backup_dir/"
    fi

    # Create the symbolic link
    if [ ! -L "$dest" ]; then
        echo "Linking $src to $dest"
        ln -sf "$src" "$dest"
    fi
}

echo "Setting up your Mac..."

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Update Homebrew
echo "Updating Homebrew..."
brew update

# Remove conflicting applications first
echo "Removing potentially conflicting applications..."
brew uninstall --cask docker balenaetcher calibre --force || true

# Install essential packages
echo "Installing essential packages..."
# Use verbose mode to see more information about the installation process
brew bundle --file="$DOTFILES_DIR/Brewfile" --verbose

# Install Oh My Zsh if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Zsh plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Create necessary directories
mkdir -p "$HOME/.config/starship"

# Link configuration files
echo "Linking configuration files..."
link_file "$CONFIG_DIR/.zshrc" "$HOME/.zshrc" "$BACKUP_DIR"
link_file "$CONFIG_DIR/.gitconfig" "$HOME/.gitconfig" "$BACKUP_DIR"
link_file "$CONFIG_DIR/.gitignore_global" "$HOME/.gitignore_global" "$BACKUP_DIR"

# Configure macOS defaults
echo "Configuring macOS defaults..."
source "$DOTFILES_DIR/scripts/macos.sh"

# Clean up Homebrew
echo "Cleaning up Homebrew..."
brew cleanup

echo "Installation complete! Please restart your terminal."