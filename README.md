# macos-bootstrap

Declarative bootstrap for a fresh Apple Silicon Mac: `setup.sh`, a `Brewfile`,
and a set of `defaults write` scripts. Idempotent — safe to re-run on a
machine that's already partially set up.

This repo is deliberately separate from
[`dotfiles`](https://github.com/NickBlomberg/dotfiles) (chezmoi-managed shell/
editor/git config). `setup.sh` clones and applies the dotfiles repo as one of
its steps, but package management and machine-level preferences live here,
not there. Don't merge the two.

## Quick start

```sh
git clone git@github.com:NickBlomberg/macos-bootstrap.git
cd macos-bootstrap
./setup.sh
```

Prompts for your sudo password once, near the start. Everything else runs
unattended except a final "log out now?" prompt at the end (some settings
only take effect after logout).

## Manual steps — can't be automated

> [!IMPORTANT]
> A handful of steps need a human, before, during, or after `setup.sh` runs.
> Nothing else in the bootstrap requires attention beyond the initial sudo
> prompt.

**Before running `setup.sh`:**
- [ ] Copy the age key from Bitwarden to `~/.config/chezmoi/key.txt` and
      `chmod 600` it — `setup.sh` exits immediately with instructions if
      it's missing (see [Prerequisites](#prerequisites))

**During `setup.sh`:**
- [ ] Approve the sudo password prompt (once, near the start)
- [ ] When Rectangle and Hyperkey first launch, grant both **Accessibility**
      permission — a TCC prompt macOS requires approving by hand (see
      [Rectangle + Hyperkey](#rectangle--hyperkey))
- [ ] Log out when prompted at the end, so trackpad gestures, keyboard
      input source, and reduce motion fully take effect

**One-time, whenever Homebrew autoupdate first runs:**
- [ ] Grant `brew_autoupdate` (plus `ruby` and Ghostty) **App
      Management** permission in System Settings → Privacy & Security, so
      in-place cask upgrades can happen (see
      [Homebrew autoupdate](#homebrew-autoupdate))

## Prerequisites

- **Apple Silicon only.** No Intel Mac support — `setup.sh` hardcodes
  `/opt/homebrew` and does no architecture detection.
- **Admin (sudo) access**, for `macos-system-defaults.sh` and (on a truly
  fresh machine) Homebrew's own installer.
- **Age key for chezmoi**, copied by hand from Bitwarden to
  `~/.config/chezmoi/key.txt` (`chmod 600`) before running `setup.sh` — it's
  required to decrypt secrets in the dotfiles repo. `setup.sh` checks for
  this and exits with instructions if it's missing.

## What `setup.sh` does

Steps are numbered in the script's own output (`[n/9]`) so a run's progress
is visible at a glance:

1. Apply system-wide macOS defaults (sudo) — done first so the one
   interactive prompt happens before everything else runs unattended
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

Followed by an offer to log out, since a few settings (trackpad gestures,
keyboard input source, reduce motion) only fully apply after one.

## Files

| File | What it is |
|---|---|
| `setup.sh` | Orchestrator. Every step lives here explicitly — nothing is hidden in hooks or `run_once_` scripts, so the whole bootstrap is readable top to bottom. |
| `Brewfile` | Formulae, casks, VS Code extensions. Reconciled to match actual `brew leaves` + `brew list --cask` output, not an idealized wishlist. |
| `macos-defaults.sh` | Per-user `defaults write` preferences (`~/Library/Preferences`) — keyboard, trackpad, Finder, Dock, screenshots, etc. No sudo required. |
| `macos-system-defaults.sh` | System-wide preferences (`/Library/Preferences`) — machine identity (hostname), timezone, power management, Touch ID for sudo. Requires sudo, kept separate from `macos-defaults.sh` for that reason. |
| `third-party-defaults.sh` | Rectangle + Hyperkey preferences — the one app-specific defaults script, isolated so it's cheap to drop if either app is ever replaced. |

## Rectangle + Hyperkey

These two apps are a linked pair: Hyperkey remaps Caps Lock to a Hyper key
(⌃⌥⌘), and Rectangle's window-tiling shortcuts are built on that chord —
Rectangle's bindings are dead without Hyperkey running.

- **Caps Lock** → Hyper (⌃⌥⌘)
- **Hyper + arrow keys** → window halves (left/right/top/bottom)
- **Hyper + F** → maximize

One thing can't be scripted and needs doing by hand on a new machine: both
apps require **Accessibility permission** on first launch (a TCC prompt
macOS requires you to approve manually).

## Homebrew autoupdate

`domt4/autoupdate` runs `brew update`/`upgrade` in the background every 24h
(`--upgrade --greedy --cleanup`, so casks are included and old versions are
cleaned up). One manual step it can't do itself: for autoupdate to perform
*in-place* cask upgrades (apps that stay pinned to the Dock), add
`~/Library/Application Support/com.github.domt4.homebrew-autoupdate/brew_autoupdate`
to **System Settings → Privacy & Security → App Management** (also allow
`ruby` and Ghostty). `setup.sh` prints a reminder the first time it
enables autoupdate.

## Design principles

- **Visibility over abstraction** — Homebrew, chezmoi, and defaults steps
  are explicit in `setup.sh`, not hidden in `run_once_` scripts or wrapper
  functions.
- **Idempotent** — every step is safe to re-run. Guards check current state
  (`command -v`, file existence, `brew autoupdate status`, etc.) rather than
  assuming a clean machine.
- **Fail loud and early** — `set -euo pipefail` throughout; missing
  prerequisites (wrong OS, missing age key) exit immediately with a clear
  message instead of failing partway through.
