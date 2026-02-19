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

echo ""
echo "✅ Your Macbook is ready."
echo ""
echo "⚠️  POST-INSTALL REMINDERS:"
echo "1. Restart your Terminal to ensure all Nix paths and Zsh settings are loaded."
echo "2. Sign in to the Mac App Store manually so that 'mas' can install/update Xcode."
echo "3. If Touch ID for sudo doesn't work immediately, try 'sudo -k' or restart your machine."
echo "4. You can update your system anytime by running the 'update' command."
