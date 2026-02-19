#!/usr/bin/env bash
set -euo pipefail

FLAKE_REPO="https://github.com/kadirlofca/nix-macbook.git"
FLAKE_DIR="$HOME/nix"
CONFIG_NAME="kadir-macbook"

echo "▶ Starting bootstrap..."

########################################
# 1️⃣ Install Nix (Determinate Installer)
########################################

if ! command -v nix >/dev/null 2>&1; then
    echo "▶ Cleaning up old Nix artifacts (if any)..."

    sudo launchctl bootout system/org.nixos.nix-daemon 2>/dev/null || true
    sudo diskutil apfs deleteVolume "Nix Store" 2>/dev/null || true

    echo "▶ Installing Nix (Determinate Systems)..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
        | sh -s -- install --no-confirm

    # Load nix into current shell
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
fi

########################################
# 2️⃣ Enable flakes explicitly
########################################

export NIX_CONFIG="experimental-features = nix-command flakes"

########################################
# 3️⃣ Clone or update flake repo
########################################

if [ ! -d "$FLAKE_DIR" ]; then
    echo "▶ Cloning configuration..."
    git clone "$FLAKE_REPO" "$FLAKE_DIR"
else
    echo "▶ Updating configuration..."
    git -C "$FLAKE_DIR" pull
fi

########################################
# 4️⃣ Install nix-darwin (first time)
########################################

if ! command -v darwin-rebuild >/dev/null 2>&1; then
    echo "▶ Installing nix-darwin..."

    nix run nix-darwin -- switch --flake "$FLAKE_DIR#$CONFIG_NAME"
else
    echo "▶ Rebuilding system..."
    darwin-rebuild switch --flake "$FLAKE_DIR#$CONFIG_NAME"
fi

########################################
# 5️⃣ Done
########################################

echo ""
echo "✅ Mac setup complete."
echo ""
echo "Post-install notes:"
echo "• Restart Terminal."
echo "• Sign into the App Store for mas/Xcode."
echo "• If Touch ID sudo needs refresh: sudo -k"
