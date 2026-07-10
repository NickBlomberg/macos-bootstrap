#!/usr/bin/env bash
#
# macos-defaults.sh — declarative macOS preferences (v2)
#
# Sources:
#   * Phase 4 structured diff (fresh account vs main account)
#   * Curated survivors from mathiasbynens/.macos (2026-verified)
#
# Every `defaults write` is idempotent: re-running converges to the same
# state. Grouped by System Settings pane for visibility.
#
# Scope: per-user preferences only. System-wide settings (pmset etc.) are
# stubbed at the bottom as a separate side quest.

set -euo pipefail

echo "==> Applying macOS defaults"

# ---------------------------------------------------------------------------
# Meta: close System Settings so an open window doesn't clobber our writes
# when it quits (it writes its in-memory state back on close)
# ---------------------------------------------------------------------------

osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# ---------------------------------------------------------------------------
# Keyboard & text input
# ---------------------------------------------------------------------------

# Fast key repeat (lower = faster)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 30

# Holding a key repeats it instead of showing the accent picker
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Don't insert a full stop on double-space
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# F1-F12 behave as media keys (fnState off)
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool false

# Keyboard layout: British
# NOTE: input source changes generally need a logout to fully apply.
defaults write com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID \
  -string "com.apple.keylayout.British"
defaults write com.apple.HIToolbox AppleEnabledInputSources -array \
  '<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>2</integer><key>KeyboardLayout Name</key><string>British</string></dict>'

# ---------------------------------------------------------------------------
# Trackpad & mouse
# ---------------------------------------------------------------------------

# Natural scrolling OFF
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Tracking speeds
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1
defaults write NSGlobalDomain com.apple.mouse.scaling -float 3

# Tap to click (both trackpad domains + per-host key)
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Swipe between pages with two-finger scroll gesture
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true

# Three-finger swipe -> pages, not full-screen apps
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 1

# Disable two-finger swipe from right edge (Notification Centre)
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0

# ---------------------------------------------------------------------------
# Appearance & motion
# ---------------------------------------------------------------------------

# Auto light/dark appearance
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# Always show scroll bars; clicking the track jumps to that spot
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
defaults write NSGlobalDomain AppleScrollerPagingBehavior -bool true

# Tone down Liquid Glass diffusion; hide icons in menus
defaults write NSGlobalDomain NSGlassDiffusionSetting -int 0
defaults write NSGlobalDomain NSMenuEnableActionImages -bool false

# Reduce motion
# Writing to com.apple.universalaccess requires Full Disk Access for the
# invoking terminal — without it this fails outright (not silently), which
# would otherwise abort the rest of this script under set -e.
if ! defaults write com.apple.universalaccess reduceMotion -bool true 2>/dev/null; then
  echo "NOTE: reduceMotion needs Full Disk Access for this terminal — grant it in System Settings > Privacy & Security > Full Disk Access, then re-run, or toggle Reduce Motion manually in System Settings > Accessibility > Display."
fi

# UI sound effects off; alert sound = Tink
defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -bool false
defaults write NSGlobalDomain com.apple.sound.beep.sound -string "/System/Library/Sounds/Tink.aiff"

# ---------------------------------------------------------------------------
# Save & print panels
# ---------------------------------------------------------------------------

# Always expand save/print dialogs
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# New documents save to disk, not iCloud
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# ---------------------------------------------------------------------------
# Screenshots
# ---------------------------------------------------------------------------

# Keep screenshots out of ~/Desktop; no window shadows
# (Adjust the path if you prefer a different vault.)
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

# ---------------------------------------------------------------------------
# Finder
# ---------------------------------------------------------------------------

# Show all filename extensions (global); no warning when changing one
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Path bar on, POSIX path in window title, folders sorted first
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# List view by default; group by Kind; search the current folder
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder FXPreferredGroupBy -string "Kind"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# New windows open in the home folder
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Desktop: show connected servers, hide removable media
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Wipe the default Finder favourite tags (Red/Orange/Yellow/...) and hide
# the separate "Recent Tags" list. NOTE: this does not remove the "Tags"
# section header itself from the sidebar — no verified defaults key for
# that; toggle it off by hand via Finder > Settings > Sidebar if wanted.
defaults write com.apple.finder FavoriteTagNames -array ""
defaults write com.apple.finder ShowRecentTags -bool false

# Don't litter network shares or USB drives with .DS_Store files
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Unhide ~/Library
chflags nohidden "${HOME}/Library"

# ---------------------------------------------------------------------------
# Dock, Mission Control & window tiling
# ---------------------------------------------------------------------------

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock tilesize -int 47
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock mineffect -string "scale"

# Pin exactly these apps in the Dock, replacing Apple's defaults
defaults write com.apple.dock persistent-apps -array \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Ghostty.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Todoist.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Firefox Developer Edition.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Obsidian.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
  '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Claude.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

# Instant Dock show/hide
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

# No "recent applications" section in the Dock
defaults write com.apple.dock show-recents -bool false

# Don't rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Disable the bottom-right hot corner (default: Quick Note)
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-br-modifier -int 0

# Displays have separate Spaces
defaults write com.apple.spaces spans-displays -bool false

# Window tiling: no margins, no drag-to-edge tiling, no option accelerator
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false

# Hide desktop widgets, and stop clicking the desktop from revealing them
# (StandardHideWidgets alone only hides them from the persistent desktop view —
# "Click wallpaper to reveal desktop" is a separate toggle that shows them
# again on click unless restricted to Stage Manager only)
defaults write com.apple.WindowManager StandardHideWidgets -bool true
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -int 0

# ---------------------------------------------------------------------------
# Apps: TextEdit, Image Capture, Time Machine
# ---------------------------------------------------------------------------

# TextEdit: plain text by default
defaults write com.apple.TextEdit RichText -int 0

# Stop Photos opening automatically when devices are plugged in
defaults write com.apple.ImageCapture disableHotPlug -bool true

# Time Machine: don't offer every new disk as a backup target
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# ---------------------------------------------------------------------------
# Software updates
# ---------------------------------------------------------------------------

defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
defaults write com.apple.commerce AutoUpdate -bool true

# ---------------------------------------------------------------------------
# Privacy
# ---------------------------------------------------------------------------

# Apple personalised ads off
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false

# ---------------------------------------------------------------------------
# Menu bar / Control Centre
# ---------------------------------------------------------------------------

# Hide Focus from menu bar
defaults write com.apple.controlcenter "NSStatusItem Visible FocusModes" -bool false

# ---------------------------------------------------------------------------
# Apply
# ---------------------------------------------------------------------------

echo "==> Restarting affected services"
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
killall ControlCenter 2>/dev/null || true

echo "==> Done."
