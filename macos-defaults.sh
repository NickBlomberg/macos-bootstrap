#!/usr/bin/env bash
# macOS system preferences applied via `defaults write`.
#
# Discovery workflow: run `prefsniff /Library/Preferences /Users/$USER/Library/Preferences`
# while making changes in System Settings, then cross-reference with
# https://github.com/mathiasbynens/dotfiles/blob/main/.macos
#
# Run: bash macos-defaults.sh
# Requires: macOS, some settings need a logout/restart to take effect.
set -euo pipefail

echo "Applying macOS defaults..."

# ── Close System Settings (prevents it overwriting our changes) ───────────────
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# ── General ───────────────────────────────────────────────────────────────────

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# ── Keyboard & Input ──────────────────────────────────────────────────────────

# Disable press-and-hold in favour of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable smart quotes and smart dashes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# ── Trackpad & Mouse ─────────────────────────────────────────────────────────

# Trackpad: enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ── Screen ────────────────────────────────────────────────────────────────────

# Require password immediately after sleep or screen saver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Save screenshots to Downloads
defaults write com.apple.screencapture location -string "${HOME}/Downloads"

# Save screenshots as PNG
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# ── Finder ────────────────────────────────────────────────────────────────────

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Use list view by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show ~/Library in Finder
chflags nohidden ~/Library

# ── Dock ─────────────────────────────────────────────────────────────────────

# Set Dock icon size
defaults write com.apple.dock tilesize -int 48

# Autohide the Dock
defaults write com.apple.dock autohide -bool true

# Remove autohide delay
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3

# Don't show recent apps in Dock
defaults write com.apple.dock show-recents -bool false

# ── Safari ────────────────────────────────────────────────────────────────────

# Show full URL in address bar
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# ── TextEdit ─────────────────────────────────────────────────────────────────

# Use plain text mode
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# ── Restart affected apps ─────────────────────────────────────────────────────
for app in "Finder" "Dock" "SystemUIServer"; do
    killall "$app" &>/dev/null || true
done

echo "Done. Some changes require a logout or restart to take effect."
