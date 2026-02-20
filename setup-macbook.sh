#!/usr/bin/env bash
set -euo pipefail

FLAKE_REPO="https://github.com/kadirlofca/nix-macbook.git"
FLAKE_DIR="$HOME/nix"
CONFIG_NAME="kadir-macbook"

echo "▶ Starting macOS bootstrap..."

########################################
# 1️⃣ Ensure not running as root
########################################
if [ "$(id -u)" -eq 0 ]; then
  echo "❌ Do NOT run this script as root."
  exit 1
fi

########################################
# 2️⃣ Install Nix if missing
########################################
if ! command -v nix >/dev/null 2>&1; then
  echo "▶ Installing Nix (Determinate Systems)..."

  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm

  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

########################################
# 3️⃣ Enable flakes
########################################
export NIX_CONFIG="experimental-features = nix-command flakes"

########################################
# 4️⃣ Clone or update flake
########################################
if [ ! -d "$FLAKE_DIR" ]; then
  echo "▶ Cloning configuration..."
  git clone "$FLAKE_REPO" "$FLAKE_DIR"
else
  echo "▶ Updating configuration..."
  git -C "$FLAKE_DIR" pull
fi

########################################
# 5️⃣ Run nix-darwin activation (root required)
########################################
echo "▶ Activating nix-darwin configuration (requires root)..."

if ! sudo nix run nix-darwin -- switch --flake "$FLAKE_DIR#$CONFIG_NAME"; then
  echo "❌ Activation failed."
  exit 1
fi

########################################
# 6️⃣ Done
########################################
echo ""
echo "✅ macOS setup complete."
echo ""
echo "Next steps:"
echo "• Restart Terminal."
echo "• Use 'darwin-rebuild switch --flake ~/nix#$CONFIG_NAME' for future updates."
