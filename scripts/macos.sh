#!/bin/zsh

###############################################################################
# Error Handling & Utility Functions                                          #
###############################################################################

# Text formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Error handling
handle_error() {
    log "error" "Error on line $1"
}

trap 'handle_error $LINENO' ERR

# Function to safely run defaults command
safe_defaults_write() {
    if ! defaults write "$@" 2>/dev/null; then
        log "warn" "Failed to set preference: defaults write $*"
    fi
}

log "info" "Configuring macOS system preferences..."

# Close any open System Preferences panes
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

log "info" "Configuring General UI/UX preferences..."

# Disable the sound effects on boot
if [[ -w /sys/firmware/efi/efivars ]]; then
    sudo nvram SystemAudioVolume=" " 2>/dev/null || true
fi

# Always show scrollbars
safe_defaults_write NSGlobalDomain AppleShowScrollBars -string "Always"

# Expand save panel by default
safe_defaults_write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
safe_defaults_write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
safe_defaults_write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
safe_defaults_write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
safe_defaults_write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
safe_defaults_write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the "Are you sure you want to open this application?" dialog
safe_defaults_write com.apple.LaunchServices LSQuarantine -bool false

# Disable automatic capitalization
safe_defaults_write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes
safe_defaults_write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution
safe_defaults_write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes
safe_defaults_write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

###############################################################################
# Trackpad, Mouse, Keyboard, and Input                                       #
###############################################################################

log "info" "Configuring input device preferences..."

# Trackpad: enable tap to click
safe_defaults_write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
safe_defaults_write com.apple.AppleMultitouchTrackpad Clicking -bool true
safe_defaults_write -g com.apple.mouse.tapBehavior -int 1

# Disable "natural" scrolling
safe_defaults_write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Enable full keyboard access for all controls
safe_defaults_write NSGlobalDomain AppleKeyboardUIMode -int 3

# Set a fast keyboard repeat rate
safe_defaults_write NSGlobalDomain KeyRepeat -int 2
safe_defaults_write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for keys in favor of key repeat
safe_defaults_write NSGlobalDomain ApplePressAndHoldEnabled -bool false

###############################################################################
# Screen                                                                      #
###############################################################################

log "info" "Configuring screen preferences..."

# Require password immediately after sleep or screen saver begins
safe_defaults_write com.apple.screensaver askForPassword -int 1
safe_defaults_write com.apple.screensaver askForPasswordDelay -int 0

# Save screenshots to Desktop
safe_defaults_write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in PNG format
safe_defaults_write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
safe_defaults_write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

log "info" "Configuring Finder preferences..."

# Set Desktop as the default location for new Finder windows
safe_defaults_write com.apple.finder NewWindowTarget -string "PfDe"
safe_defaults_write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# Show icons for hard drives, servers, and removable media on the desktop
safe_defaults_write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
safe_defaults_write com.apple.finder ShowHardDrivesOnDesktop -bool true
safe_defaults_write com.apple.finder ShowMountedServersOnDesktop -bool true
safe_defaults_write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Show all filename extensions
safe_defaults_write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar
safe_defaults_write com.apple.finder ShowStatusBar -bool true

# Show path bar
safe_defaults_write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
safe_defaults_write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
safe_defaults_write com.apple.finder _FXSortFoldersFirst -bool true

# Search current folder by default
safe_defaults_write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
safe_defaults_write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
safe_defaults_write com.apple.desktopservices DSDontWriteNetworkStores -bool true
safe_defaults_write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
safe_defaults_write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show the ~/Library folder
chflags nohidden ~/Library || true

# Show the /Volumes folder
sudo chflags nohidden /Volumes || true

###############################################################################
# Dock                                                                        #
###############################################################################

log "info" "Configuring Dock preferences..."

# Set the icon size of Dock items
safe_defaults_write com.apple.dock tilesize -int 48

# Enable magnification
safe_defaults_write com.apple.dock magnification -bool true
safe_defaults_write com.apple.dock largesize -int 64

# Position the Dock on the left
safe_defaults_write com.apple.dock orientation -string "left"

# Minimize windows into their application's icon
safe_defaults_write com.apple.dock minimize-to-application -bool true

# Don't automatically rearrange Spaces based on most recent use
safe_defaults_write com.apple.dock mru-spaces -bool false

# Remove the auto-hiding Dock delay
safe_defaults_write com.apple.dock autohide-delay -float 0

# Speed up the animation when hiding/showing the Dock
safe_defaults_write com.apple.dock autohide-time-modifier -float 0.3

# Automatically hide and show the Dock
safe_defaults_write com.apple.dock autohide -bool true

# Don't show recent applications in Dock
safe_defaults_write com.apple.dock show-recents -bool false

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

echo "Note: Safari preferences must be set manually due to security restrictions."
echo "Please configure the following settings in Safari manually:"
echo "- Disable search suggestions in Safari preferences"
echo "- Show full URL in address bar"
echo "- Enable Developer menu in Safari preferences"
echo "- Set homepage to about:blank if desired"

###############################################################################
# Mail                                                                        #
###############################################################################

echo "Note: Mail preferences must be set manually due to security restrictions."
echo "Please configure the following settings in Mail manually:"
echo "- Customize email address copying format in Mail preferences"

###############################################################################
# Terminal & iTerm2                                                          #
###############################################################################

log "info" "Configuring Terminal preferences..."

# Only use UTF-8 in Terminal.app
safe_defaults_write com.apple.terminal StringEncodings -array 4

# Don't display the annoying prompt when quitting iTerm
safe_defaults_write com.googlecode.iterm2 PromptOnQuit -bool false

###############################################################################
# Activity Monitor                                                            #
###############################################################################

log "info" "Configuring Activity Monitor preferences..."

# Show the main window when launching Activity Monitor
safe_defaults_write com.apple.ActivityMonitor OpenMainWindow -bool true

# Show all processes
safe_defaults_write com.apple.ActivityMonitor ShowCategory -int 0

# Sort by CPU usage
safe_defaults_write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
safe_defaults_write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# TextEdit                                                                    #
###############################################################################

echo "Configuring TextEdit preferences..."

# Use plain text mode for new documents
safe_defaults_write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8
safe_defaults_write com.apple.TextEdit PlainTextEncoding -int 4
safe_defaults_write com.apple.TextEdit PlainTextEncodingForWrite -int 4

###############################################################################
# Photos                                                                      #
###############################################################################

echo "Configuring Photos preferences..."

# Prevent Photos from opening automatically when devices are plugged in
safe_defaults_write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Mac App Store                                                               #
###############################################################################

echo "Configuring Mac App Store preferences..."

# Enable the automatic update check
safe_defaults_write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily
safe_defaults_write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
safe_defaults_write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
safe_defaults_write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Turn on app auto-update
safe_defaults_write com.apple.commerce AutoUpdate -bool true

###############################################################################
# AI Development Tools                                                        #
###############################################################################

echo "Setting up AI development tools..."

# Install Python dependencies 
echo "Installing Python and package management tools..."
brew install python pyenv

# Install Rust and UV
echo "Installing UV - Modern Python Package Manager..."
brew install rustup || {
    echo "⚠️  Failed to install rustup. Attempting to continue..."
}

if command -v rustup &> /dev/null; then
    echo "Initializing Rust..."
    rustup-init -y --no-modify-path || {
        echo "⚠️  Failed to initialize Rust. UV installation may fail."
    }
    
    # Source Cargo environment to ensure it's in PATH
    [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
    
    # Install UV via pip as a more reliable method
    echo "Installing UV..."
    python3 -m pip install uv || {
        echo "⚠️  Failed to install UV via pip. Trying cargo method as fallback..."
        
        # Check if cargo is available
        if command -v cargo &> /dev/null; then
            echo "Installing UV via Cargo..."
            cargo install uv || {
                echo "⚠️  Failed to install UV via Cargo."
            }
        else
            echo "⚠️  Cargo not found in PATH. Cannot install UV via Cargo."
        fi
    }
    
    # Verify UV installation
    if command -v uv &> /dev/null; then
        echo "Configuring UV..."
        uv self update || echo "⚠️  Failed to update UV."
        echo "✅ UV installation complete"
    else
        echo "⚠️  UV not found in PATH after installation. Adding Cargo bin to current PATH..."
        export PATH="$HOME/.cargo/bin:$PATH"
        
        # Check again with updated PATH
        if command -v uv &> /dev/null; then
            echo "✅ UV found in Cargo bin directory"
        else
            echo "❌ UV installation failed. Please install manually."
        fi
    fi
else
    echo "⚠️  Rustup not found. Trying direct pip installation..."
    python3 -m pip install uv || {
        echo "❌ Failed to install UV via pip. Please install manually."
    }
fi

# Install Aider (AI pair programming tool)
echo "Installing Aider using UV or pip..."
if command -v uv &> /dev/null; then
    # If we're in a shell script, create a temporary venv for installation
    if [ ! -n "$VIRTUAL_ENV" ]; then
        TEMP_VENV=$(mktemp -d)/aider-venv
        echo "Creating temporary virtual environment for Aider installation..."
        uv venv "$TEMP_VENV"
        source "$TEMP_VENV/bin/activate"
    fi
    
    # Now install with UV in the venv or current environment
    uv pip install aider-chat || {
        echo "⚠️  Failed to install Aider with UV. Falling back to pip..."
        python3 -m pip install -U pip
        python3 -m pip install aider-chat
    }
    
    # Deactivate temporary venv if we created one
    if [ -d "$TEMP_VENV" ]; then
        echo "Cleaning up temporary environment..."
        deactivate
        rm -rf "$TEMP_VENV"
    fi
else
    echo "UV not found, using pip as fallback..."
    python3 -m pip install -U pip
    python3 -m pip install aider-chat
fi

# Verify Aider installation
if command -v aider &> /dev/null; then
    echo "✅ Aider installation complete"
else
    echo "⚠️  Aider might not be in PATH. You may need to reinstall or add it to your PATH manually."
fi

# Install Go (required for Goose)
echo "Installing Go for Goose..."
brew install go

# Setup Goose from Block
echo "Setting up Goose..."
if [ ! -d "$HOME/.goose" ]; then
    mkdir -p "$HOME/.goose"
    echo "Created Goose directory at $HOME/.goose"
fi

# Install or update Goose CLI
if [ ! -f "$HOME/.goose/bin/goose" ]; then
    echo "Installing Goose CLI..."
    curl -fsSL https://block.github.io/goose/install.sh | sh
else
    echo "Updating Goose CLI..."
    curl -fsSL https://block.github.io/goose/install.sh | sh
fi

# Create .zshrc.local from template if it doesn't exist
if [ ! -f "$HOME/.zshrc.local" ]; then
    echo "Creating .zshrc.local from template..."
    cp "$HOME/Projects/dotfiles/config/.zshrc.local.template" "$HOME/.zshrc.local"
    
    echo ""
    echo "⚠️  IMPORTANT: Edit ~/.zshrc.local to add your API keys!"
    echo "  • OpenAI API key for Aider: https://platform.openai.com/"
    echo "  • Anthropic API key (optional): https://console.anthropic.com/"
    echo "  • Goose API key: https://block.github.io/goose/docs/quickstart/"
    echo "  • See the AI Coding Tools section in README.md for more details"
    echo ""
else
    echo ".zshrc.local already exists. Not overwriting."
fi

# Final instructions
echo ""
echo "🎉 AI development tools setup complete!"
echo ""
echo "To start using AI coding tools:"
echo "  • Aider: run 'aider' in your project directory"
echo "  • Goose: run 'goose' in your project directory"
echo ""
echo "Remember to add your API keys to ~/.zshrc.local"
echo ""

###############################################################################
# Restart affected applications                                              #
###############################################################################

log "info" "Restarting affected applications..."

# Restart Finder
killall Finder || true

# Restart Dock
killall Dock || true

# Restart SystemUIServer
killall SystemUIServer || true

log "success" "macOS configuration complete. Some changes require a logout/restart to take effect."