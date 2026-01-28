#!/usr/bin/env bash
# Create symlinks for dotfiles

set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$DOTFILES_DIR/backup"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to backup existing files
backup_file() {
    local file="$1"
    if [[ -f "$file" ]] || [[ -d "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        local backup_name="$(basename "$file").backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $file to $BACKUP_DIR/$backup_name"
        mv "$file" "$BACKUP_DIR/$backup_name"
    fi
}

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        print_error "Source file does not exist: $source"
        return 1
    fi

    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$target")"

    # Backup existing file if it exists and is not already a symlink to our dotfiles
    if [[ -e "$target" ]] && [[ "$(readlink "$target")" != "$source" ]]; then
        backup_file "$target"
    fi

    # Remove existing symlink if it exists
    [[ -L "$target" ]] && rm "$target"

    # Create the symlink
    ln -s "$source" "$target"
    print_status "Created symlink: $target -> $source"
}

print_status "Setting up dotfiles symlinks..."

# Zsh configuration
create_symlink "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"

# Starship configuration
create_symlink "$DOTFILES_DIR/config/starship/starship.toml" "$HOME/.config/starship/starship.toml"

# Ghostty configuration
create_symlink "$DOTFILES_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"

# Git configuration (if it exists)
if [[ -f "$HOME/.gitconfig" ]]; then
    cp "$HOME/.gitconfig" "$DOTFILES_DIR/config/git/.gitconfig"
    create_symlink "$DOTFILES_DIR/config/git/.gitconfig" "$HOME/.gitconfig"
fi

# OpenCode configuration
create_symlink "$DOTFILES_DIR/config/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
create_symlink "$DOTFILES_DIR/config/opencode/skills" "$HOME/.config/opencode/skills"

print_status "Dotfiles symlinks created successfully!"
print_status "Don't forget to restart your terminal or run: source ~/.zshrc"