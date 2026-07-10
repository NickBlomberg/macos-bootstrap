#!/usr/bin/env bash
# macos-system-defaults.sh — system-wide (sudo-required) preferences
#
# Separate from macos-defaults.sh (per-user) by design — different privilege
# level, different domain (/Library/Preferences vs ~/Library/Preferences).

set -euo pipefail

echo "==> Applying system-wide macOS defaults (requires sudo)"
sudo -v   # cache credentials up front rather than prompting mid-script

# ---------------------------------------------------------------------------
# Identity
# ---------------------------------------------------------------------------

sudo scutil --set ComputerName "Manaslu"
sudo scutil --set LocalHostName "Manaslu"
sudo scutil --set HostName "Manaslu"

# ---------------------------------------------------------------------------
# Time
# ---------------------------------------------------------------------------

# systemsetup has a long-standing cosmetic bug (Error:-99, InternetServices.m)
# that prints on virtually every -set* call across every macOS version, despite
# the setting applying successfully. `|| true` swallows that known-harmless
# non-zero exit so `set -e` doesn't abort the rest of the script.
sudo systemsetup -settimezone "Europe/London" > /dev/null 2>&1 || true
sudo systemsetup -setusingnetworktime on > /dev/null 2>&1 || true

# ---------------------------------------------------------------------------
# Power management
# ---------------------------------------------------------------------------

sudo pmset -a lidwake 1        # wake on lid open
sudo pmset -a autorestart 1    # restart on power loss
sudo pmset -b displaysleep 15  # display sleep on battery (minutes)
sudo pmset -c displaysleep 30  # display sleep on charger

# ---------------------------------------------------------------------------
# Touch ID for sudo (Sonoma+ persistent method — survives macOS updates)
# ---------------------------------------------------------------------------

if [[ ! -f /etc/pam.d/sudo_local ]]; then
  sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
  sudo sed -i '' 's/^#auth/auth/' /etc/pam.d/sudo_local
fi

# ---------------------------------------------------------------------------
# Remote login: explicitly assert OFF (declarative guard)
# ---------------------------------------------------------------------------

sudo systemsetup -setremotelogin off > /dev/null 2>&1 || true

echo "==> System-wide defaults applied."
