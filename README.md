# macos-bootstrap

Declarative bootstrap for a fresh Apple Silicon Mac: `setup.sh`, a `Brewfile`,
and a set of `defaults write` scripts.

Package management and machine-level preferences live here. Shell/editor/git
config lives in the separate [`dotfiles`](https://github.com/NickBlomberg/dotfiles)
repo, which `setup.sh` clones and applies via chezmoi as one of its steps.

## Quick start

- Apple Silicon only — no Intel support
- Requires admin (sudo) access

> [!WARNING]
> **Copy the age key from Bitwarden first**, to `~/.config/chezmoi/key.txt`:
> ```sh
> mkdir -p ~/.config/chezmoi && vi ~/.config/chezmoi/key.txt
> chmod 600 ~/.config/chezmoi/key.txt
> ```
> Without it, `setup.sh` runs most of the way through (Homebrew, packages,
> etc.) before failing at the dotfiles step — copy the key first and skip
> that wasted run.

On a fresh Mac, download this repo directly — no git, Xcode tools, or GitHub
auth required yet:

```sh
curl -sL https://github.com/NickBlomberg/macos-bootstrap/archive/refs/heads/main.tar.gz | tar xz
cd macos-bootstrap-main
./setup.sh
```

> [!NOTE]
> Avoid `git clone` here — `git` needs Xcode Command Line Tools to run at
> all, and invoking it on a fresh machine triggers that install popup
> (easy to miss if it opens behind the terminal). If you already have git,
> use the HTTPS form — `git clone https://github.com/NickBlomberg/macos-bootstrap.git`
> — not the `git@github.com:...` SSH form, which needs a registered SSH key.

## What `setup.sh` does

Steps are numbered in the script's own output (`[n/9]`):

1. Apply system-wide macOS defaults (sudo) — done first, before everything
   else runs unattended
2. Install Xcode Command Line Tools
3. Install Homebrew
4. Trust the `domt4/autoupdate` tap (Homebrew 6.0+ requires explicit trust
   for third-party taps)
5. Install packages from the `Brewfile`
6. Enable Homebrew's background autoupdate (launchd agent, 24h interval)
7. Apply dotfiles via chezmoi (clone on first run, `chezmoi update` on
   reruns)
8. Apply per-user macOS defaults (`macos-defaults.sh`)
9. Apply third-party app defaults (`third-party-defaults.sh`)

Ends with an offer to log out — see [Manual steps](#manual-steps--cant-be-automated).

## Manual steps — can't be automated

> [!IMPORTANT]
> A handful of steps need a human, during or after `setup.sh` runs. Nothing
> else requires attention beyond the initial sudo prompt.

- [ ] Approve the sudo password prompt near the start (and be ready for
      more: Homebrew's own installer may ask again on a truly fresh
      machine, and some casks — e.g. Google Drive — prompt for an admin
      password mid-`brew bundle install`)
- [ ] Click through the **Xcode Command Line Tools** installer popup
      (Install → accept the license) — the script just polls until it's done
- [ ] When Rectangle and Hyperkey first launch, grant both **Accessibility**
      permission (a TCC prompt macOS requires approving manually)
- [ ] Log out when prompted at the end, so trackpad gestures, keyboard
      input source, reduce motion, and the screen saver password fully
      take effect
- [ ] The first time Homebrew autoupdate runs, grant `brew_autoupdate`
      (plus `ruby` and Ghostty) **App Management** permission in System
      Settings → Privacy & Security (see [Homebrew autoupdate](#homebrew-autoupdate))

## Files

| File | What it is |
|---|---|
| `setup.sh` | Orchestrator. Every step lives here explicitly — nothing is hidden in hooks or `run_once_` scripts, so the whole bootstrap is readable top to bottom. |
| `Brewfile` | Formulae, casks, VS Code extensions. Reconciled to match actual `brew leaves` + `brew list --cask` output, not an idealized wishlist. |
| `macos-defaults.sh` | Per-user `defaults write` preferences (`~/Library/Preferences`) — keyboard, trackpad, Finder, Dock, screenshots, etc. No sudo required. |
| `macos-system-defaults.sh` | System-wide preferences (`/Library/Preferences`) — machine identity (hostname), timezone, power management, Touch ID for sudo. Requires sudo, kept separate from `macos-defaults.sh` for that reason. |
| `third-party-defaults.sh` | Rectangle + Hyperkey preferences — the one app-specific defaults script, isolated so it's cheap to drop if either app is ever replaced. |
| `wallpaper.jpg` | Desktop wallpaper, applied via `desktoppr` (a Brewfile cask) in `macos-defaults.sh` — `defaults write` alone can't reliably set the desktop picture on modern macOS. |

## Homebrew autoupdate

`domt4/autoupdate` runs `brew update`/`upgrade` in the background every 24h
(`--upgrade --greedy --cleanup`, so casks are included and old versions are
cleaned up). One manual step it can't do itself: for autoupdate to perform
*in-place* cask upgrades (apps that stay pinned to the Dock), add
`~/Library/Application Support/com.github.domt4.homebrew-autoupdate/brew_autoupdate`
to **System Settings → Privacy & Security → App Management** (also allow
`ruby` and Ghostty). `setup.sh` prints a reminder the first time it
enables autoupdate.
