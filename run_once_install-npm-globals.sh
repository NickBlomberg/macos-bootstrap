#!/usr/bin/env bash
# Installs global npm packages. Separated from Brewfile because npm globals
# break across Node major version upgrades and need deliberate re-installation.
set -euo pipefail

npm install -g typescript vercel
