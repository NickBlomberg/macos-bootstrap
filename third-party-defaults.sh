#!/usr/bin/env bash
#
# third-party-defaults.sh — Rectangle + Hyperkey preferences
#
# Extracted from the Phase 4 diff. These two apps form a linked set:
# Hyperkey remaps Caps Lock -> ⌃⌥⌘ (modifierFlags 1835008), and Rectangle's
# bindings are built on that Hyper chord. Apply both or neither.
#
# Key/flag decoder:
#   modifierFlags 1835008 = ⌃⌥⌘ (Hyper)
#   keyCode: 123=← 124=→ 125=↓ 126=↑ 3=F 57=CapsLock
#
# IMPORTANT: both apps cache preferences while running. Quit them before
# writing, or the in-memory state clobbers these values on exit.

set -euo pipefail

echo "==> Applying third-party app defaults"

# Quit apps so our writes aren't overwritten (ignore if not running)
osascript -e 'quit app "Rectangle"' 2>/dev/null || true
osascript -e 'quit app "Hyperkey"' 2>/dev/null || true
sleep 1

# ---------------------------------------------------------------------------
# Hyperkey — Caps Lock becomes ⌃⌥⌘ (the foundation of the set)
# ---------------------------------------------------------------------------

defaults write com.knollsoft.Hyperkey keyRemap -int 1
defaults write com.knollsoft.Hyperkey physicalKeycode -int 57   # Caps Lock
defaults write com.knollsoft.Hyperkey capsLockRemapped -int 2
defaults write com.knollsoft.Hyperkey hyperFlags -int 1835008   # ⌃⌥⌘
defaults write com.knollsoft.Hyperkey executeQuickHyperKey -int 2
defaults write com.knollsoft.Hyperkey hideMenuBarIcon -bool true
defaults write com.knollsoft.Hyperkey launchOnLogin -bool true
defaults write com.knollsoft.Hyperkey SUEnableAutomaticChecks -bool true
defaults write com.knollsoft.Hyperkey disabledApps -string '["com.apple.loginwindow"]'

# ---------------------------------------------------------------------------
# Rectangle — window management on the Hyper chord
# ---------------------------------------------------------------------------

# Behaviour
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
defaults write com.knollsoft.Rectangle hideMenubarIcon -bool false
defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -bool false
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1
defaults write com.knollsoft.Rectangle SUEnableAutomaticChecks -bool false

# Keybinds — Hyper (⌃⌥⌘, via Caps Lock) + arrows/F
defaults write com.knollsoft.Rectangle leftHalf \
  '<dict><key>keyCode</key><integer>123</integer><key>modifierFlags</key><integer>1835008</integer></dict>'
defaults write com.knollsoft.Rectangle rightHalf \
  '<dict><key>keyCode</key><integer>124</integer><key>modifierFlags</key><integer>1835008</integer></dict>'
defaults write com.knollsoft.Rectangle topHalf \
  '<dict><key>keyCode</key><integer>126</integer><key>modifierFlags</key><integer>1835008</integer></dict>'
defaults write com.knollsoft.Rectangle bottomHalf \
  '<dict><key>keyCode</key><integer>125</integer><key>modifierFlags</key><integer>1835008</integer></dict>'
defaults write com.knollsoft.Rectangle maximize \
  '<dict><key>keyCode</key><integer>3</integer><key>modifierFlags</key><integer>1835008</integer></dict>'

# ---------------------------------------------------------------------------
# Relaunch (both are login items, but bring them back now)
# ---------------------------------------------------------------------------

open -a Rectangle 2>/dev/null || true
open -a Hyperkey  2>/dev/null || true
