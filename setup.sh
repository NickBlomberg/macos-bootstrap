#!/usr/bin/env bash
set -euo pipefail

# Only run on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo "Error: this script only supports macOS (Darwin). Detected: $(uname)." >&2
  exit 1
fi

# Xcode CLI tools
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
fi

# Homebrew (install if missing, then put it on PATH for this shell — Apple Silicon only)
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

# Install packages from the Brewfile (installs chezmoi, among other things)
brew bundle install --file=Brewfile

# Age key must be manually copied from Bitwarden before dotfiles can be decrypted
AGE_KEY="$HOME/.config/chezmoi/key.txt"
if [[ ! -f "$AGE_KEY" ]]; then
  echo "Error: age key not found at $AGE_KEY" >&2
  echo "  Retrieve it from Bitwarden and place it there, then run: chmod 600 $AGE_KEY" >&2
  exit 1
fi

# Apply dotfiles via chezmoi (clone on first run, pull latest on reruns)
if [[ ! -d "$HOME/.local/share/chezmoi" ]]; then
  chezmoi init --apply https://github.com/NickBlomberg/dotfiles.git
else
  chezmoi update
fi

# Apply macOS defaults
bash macos-defaults.sh

# Apply third-party app (Rectangle, Hyperkey) defaults
bash third-party-defaults.sh

# Some settings (trackpad gestures, input sources, reduce motion) only fully
# apply after a logout. Offer one now that all bootstrap steps are done.
if [[ -t 0 ]]; then
  read -r -p "Some settings need a logout to apply. Log out now? [y/N] " reply
  if [[ "${reply}" =~ ^[Yy]$ ]]; then
    osascript -e 'tell application "System Events" to log out'
  else
    echo "Skipped logout. Remember to log out before judging trackpad/input settings."
  fi
else
  echo "Non-interactive run: log out manually to apply input settings."
fi
