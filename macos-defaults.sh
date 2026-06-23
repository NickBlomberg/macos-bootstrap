#!/usr/bin/env bash
# macOS system defaults.
#
# Capture your own adjustments here. Workflow:
#   1. brew install prefsniff
#   2. prefsniff watch <domain>   # while changing a setting in System Settings
#   3. paste the emitted `defaults write` command below
#
# Cross-reference: https://github.com/mathiasbynens/dotfiles/blob/main/.macos
set -euo pipefail

# Close System Settings so it doesn't overwrite changes.
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# --- defaults go here ---

