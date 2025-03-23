#!/bin/bash

###############################################################################
# Error Handling & Utility Functions                                          #
###############################################################################

# Error handling
handle_error() {
    echo "⚠️  Error on line $1"
}

trap 'handle_error $LINENO' ERR

# Function to safely run defaults command
safe_defaults_write() {
    if ! defaults write "$@" 2>/dev/null; then
        echo "⚠️  Failed to set preference: defaults write $*"
    fi
}

# Close any open System Preferences panes
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

echo "Configuring General UI/UX preferences..."

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

echo "Configuring input device preferences..."

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

echo "Configuring screen preferences..."

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

echo "Configuring Finder preferences..."

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

echo "Configuring Dock preferences..."

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

echo "Configuring Terminal preferences..."

# Only use UTF-8 in Terminal.app
safe_defaults_write com.apple.terminal StringEncodings -array 4

# Don't display the annoying prompt when quitting iTerm
safe_defaults_write com.googlecode.iterm2 PromptOnQuit -bool false

###############################################################################
# Activity Monitor                                                            #
###############################################################################

echo "Configuring Activity Monitor preferences..."

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
# Kill affected applications                                                  #
###############################################################################

echo "Restarting affected applications..."

apps_to_restart=(
    "Activity Monitor"
    "Address Book"
    "Calendar"
    "cfprefsd"
    "Contacts"
    "Dock"
    "Finder"
    "Mail"
    "Photos"
    "Safari"
    "SystemUIServer"
    "Terminal"
    "iCal"
)

for app in "${apps_to_restart[@]}"; do
    killall "${app}" &>/dev/null || true
done

echo "✅ Done! Note that some of these changes require a logout/restart to take effect."
echo "🔄 Please log out and back in to ensure all settings are applied correctly."