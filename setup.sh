#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/NickBlomberg/macos-bootstrap.git"
SRC="$HOME/.local/share/chezmoi"

# 1. Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  xcode-select --install
  echo "Install Xcode CLI tools via the dialog, then re-run this script."
  exit 0
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ "$(uname -m)" == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. Clone dotfiles
if [[ -d "$SRC/.git" ]]; then
  git -C "$SRC" pull --ff-only
else
  git clone "$REPO" "$SRC"
fi

# 4. Install packages
brew bundle install --file="$SRC/Brewfile"

# 5. Apply dotfiles (fires run_once_ scripts)
chezmoi apply

# 6. macOS defaults
[[ "$(uname)" == "Darwin" ]] && bash "$SRC/macos-defaults.sh"
