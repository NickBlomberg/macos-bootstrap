#!/usr/bin/env bash
set -euo pipefail

# Only run on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo "Error: this script only supports macOS (Darwin). Detected: $(uname)." >&2
  exit 1
fi

# Apply system-wide macOS defaults (requires sudo) — done first so the one
# interactive sudo prompt happens before a long unattended install, and so
# the script fails early if the user isn't an admin.
echo "[1/9] Applying system-wide macOS defaults"
bash macos-system-defaults.sh

# Xcode CLI tools
echo "[2/9] Installing Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  xcode-select --install
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
fi

# Homebrew (install if missing, then put it on PATH for this shell — Apple Silicon only)
echo "[3/9] Installing Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

# Homebrew 6.0+ requires explicit trust for third-party taps before their
# Ruby code loads. Declared in Brewfile too (tap "domt4/autoupdate", trusted:
# true), but that alone has a history of being silently dropped for taps
# without a custom remote (Homebrew/brew#22668) — this is belt-and-braces.
echo "[4/9] Trusting domt4/autoupdate tap"
brew trust domt4/autoupdate

# Install packages from the Brewfile (installs chezmoi, among other things).
# A handful of vscode extensions are known to fail on a truly fresh install
# (brew bundle installs the VS Code cask and its extensions in the same run,
# before VS Code has ever launched to create ~/.vscode/extensions/extensions.json)
# — don't let that non-fatal, well-known flakiness halt the rest of the bootstrap.
echo "[5/9] Installing packages from Brewfile"
brew bundle install --file=Brewfile || echo "WARNING: brew bundle reported failures (see above) — continuing anyway. Re-run 'brew bundle install --file=Brewfile' later to retry."

# Enable background Homebrew updates (launchd agent, 24h interval)
echo "[6/9] Enabling background Homebrew updates"
if ! brew autoupdate status | grep -q "installed and running"; then
  # A brand-new user account has never had a per-user LaunchAgent installed,
  # so ~/Library/LaunchAgents may not exist yet — brew autoupdate start
  # errors out rather than creating it itself.
  mkdir -p "$HOME/Library/LaunchAgents"
  brew autoupdate start --upgrade --greedy --cleanup
  echo "REMINDER: for in-place cask updates, add ~/Library/Application Support/com.github.domt4.homebrew-autoupdate/brew_autoupdate to System Settings > Privacy & Security > App Management (also allow ruby and Ghostty). One-time manual step, cannot be scripted."
fi

# Age key must be manually copied from Bitwarden before dotfiles can be decrypted
AGE_KEY="$HOME/.config/chezmoi/key.txt"
if [[ ! -f "$AGE_KEY" ]]; then
  echo "Error: age key not found at $AGE_KEY" >&2
  echo "  Retrieve it from Bitwarden and place it there, then run: chmod 600 $AGE_KEY" >&2
  exit 1
fi

# Apply dotfiles via chezmoi (clone on first run, pull latest on reruns)
echo "[7/9] Applying dotfiles via chezmoi"
if [[ ! -d "$HOME/.local/share/chezmoi" ]]; then
  chezmoi init --apply https://github.com/NickBlomberg/dotfiles.git
else
  chezmoi update
fi

# Apply macOS defaults
echo "[8/9] Applying macOS defaults"
bash macos-defaults.sh

# Apply third-party app (Rectangle, Hyperkey) defaults
echo "[9/9] Applying third-party app defaults"
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
