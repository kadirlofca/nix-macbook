#!/usr/bin/env bash
set -euo pipefail

FLAKE_REPO="https://github.com/kadirlofca/nix-macbook.git"
FLAKE_DIR="$HOME/nix"
CONFIG_NAME="kadir-macbook"

if ! command -v nix >/dev/null 2>&1; then
    echo "Installing Nix using Determinate Systems installer..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
fi

export NIX_CONFIG="experimental-features = nix-command flakes"

if [ ! -d "$FLAKE_DIR" ]; then
    git clone "$FLAKE_REPO" "$FLAKE_DIR"
else
    cd "$FLAKE_DIR" && git pull
fi

if command -v darwin-rebuild >/dev/null 2>&1; then
    darwin-rebuild switch --flake "$FLAKE_DIR#$CONFIG_NAME"
else
    nix run nix-darwin -- switch --flake "$FLAKE_DIR#$CONFIG_NAME"
fi

echo "✅ Your Macbook is ready."
