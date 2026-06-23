#!/usr/bin/env bash
# Bootstraps vim-plug for Neovim and installs all plugins headlessly.
set -euo pipefail

PLUG_PATH="$HOME/.local/share/nvim/site/autoload/plug.vim"

if [[ ! -f "$PLUG_PATH" ]]; then
    curl -fLo "$PLUG_PATH" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

nvim --headless +PlugInstall +qall 2>/dev/null || true
