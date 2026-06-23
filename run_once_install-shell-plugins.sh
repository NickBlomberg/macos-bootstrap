#!/usr/bin/env bash
# Installs ZSH plugins and Tmux Plugin Manager.
# chezmoi runs this once (re-runs only if this file's content changes).
set -euo pipefail

ZSH_DIR="$HOME/.zsh"
mkdir -p "$ZSH_DIR"

if [[ ! -d "$ZSH_DIR/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_DIR/zsh-syntax-highlighting"
fi

if [[ ! -d "$ZSH_DIR/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        "$ZSH_DIR/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_DIR/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$ZSH_DIR/powerlevel10k"
fi

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
