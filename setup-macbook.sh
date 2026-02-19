#!/usr/bin/env bash
set -euo pipefail

FLAKE_REPO="https://github.com/kadirlofca/nix-macbook.git"
FLAKE_DIR="$HOME/nix"
CONFIG_NAME="kadir-macbook"

echo "▶ Starting macOS bootstrap..."

########################################
# 1️⃣ Ensure running as normal user
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

  # Clean stale keychain entries (safe no-op if none exist)
  while sudo security delete-generic-password \
      -a "Nix Store" \
      -s "Nix Store" \
      -D "Encrypted volume password" >/dev/null 2>&1; do
    :
  done

  # Remove stale APFS volume if it exists
  if diskutil apfs list | grep -q "Nix Store"; then
    sudo diskutil apfs deleteVolume "Nix Store" || true
  fi

  # Install
  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm

  # Load nix into current shell
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
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
# 5️⃣ Run user-level home-manager / nix-darwin
########################################
echo "▶ Applying user-level configuration..."
if command -v darwin-rebuild >/dev/null 2>&1; then
  darwin-rebuild switch --flake "$FLAKE_DIR#$CONFIG_NAME"
else
  nix run nix-darwin -- switch --flake "$FLAKE_DIR#$CONFIG_NAME"
fi

########################################
# 6️⃣ Run system activation as root
########################################
echo "▶ Running final system-level activation (requires root)..."
sudo -E darwin-rebuild switch --flake "$FLAKE_DIR#$CONFIG_NAME"

########################################
# 6️⃣ Run system activation as root
########################################
echo "▶ Running final system-level activation (requires root)..."
sudo -E darwin-rebuild switch --flake "$FLAKE_DIR#$CONFIG_NAME"

########################################
# 7️⃣ Done
########################################
echo ""
echo "✅ macOS setup complete."
echo ""
echo "Next steps:"
echo "• Restart Terminal."
echo "• Sign into App Store for mas/Xcode."
echo "• Use 'darwin-rebuild switch --flake ~/nix#$CONFIG_NAME' to update."
