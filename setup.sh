#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="https://github.com/NickBlomberg/macos-bootstrap.git"
CHEZMOI_SOURCE="$HOME/.local/share/chezmoi"

# ── Output helpers ────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

step()    { echo -e "\n${BOLD}▶ $1${NC}"; }
ok()      { echo -e "  ${GREEN}✓${NC} $1"; }
skip()    { echo -e "  ${YELLOW}–${NC} $1 (already done)"; }
die()     { echo -e "  ${RED}✗${NC} $1" >&2; exit 1; }

# ── 1. Xcode CLI Tools ───────────────────────────────────────────────────────
step "Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
    skip "Xcode CLI tools"
else
    echo "  A dialog will appear — click Install, then re-run this script."
    xcode-select --install
    exit 0
fi

# ── 2. Homebrew ──────────────────────────────────────────────────────────────
step "Homebrew"
if command -v brew &>/dev/null; then
    skip "Homebrew"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    ok "Homebrew installed"
fi

# ── 3. Clone dotfiles repo ───────────────────────────────────────────────────
step "Dotfiles repo"
if [[ -d "$CHEZMOI_SOURCE/.git" ]]; then
    git -C "$CHEZMOI_SOURCE" pull --ff-only
    skip "Repo already present — pulled latest"
else
    git clone "$DOTFILES_REPO" "$CHEZMOI_SOURCE"
    ok "Cloned to $CHEZMOI_SOURCE"
fi

# ── 4. brew bundle ───────────────────────────────────────────────────────────
step "Homebrew packages (Brewfile)"
brew bundle install --file="$CHEZMOI_SOURCE/Brewfile" --no-lock
ok "Packages up to date"

# ── 5. chezmoi apply ─────────────────────────────────────────────────────────
step "Dotfiles (chezmoi apply)"
chezmoi apply
ok "Dotfiles applied"

# ── 6. macOS defaults ────────────────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
    step "macOS defaults"
    bash "$CHEZMOI_SOURCE/macos-defaults.sh"
    ok "Defaults applied — some changes require a logout/restart"
fi

echo -e "\n${BOLD}${GREEN}Bootstrap complete.${NC} Restart your terminal for all changes to take effect.\n"
