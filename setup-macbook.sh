#!/usr/bin/env bash
set -euo pipefail

FLAKE_REPO="https://github.com/kadirlofca/nix-macbook.git"
FLAKE_DIR="$HOME/nix"
CONFIG_NAME="kadir-macbook"

echo "▶ Starting macOS bootstrap..."

########################################
# 1️⃣ Ensure script is run as normal user
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

  # Install Nix
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
# 5️⃣ Apply user-level configuration
########################################
echo "▶ Applying user-level configuration..."
if command -v darwin-rebuild >/dev/null 2>&1; then
  darwin-rebuild switch --flake "$FLAKE_DIR#$CONFIG_NAME" || \
    echo "⚠️ Warning: User-level activation encountered an issue, continuing..."
else
  nix run nix-darwin -- switch --flake "$FLAKE_DIR#$CONFIG_NAME" || \
    echo "⚠️ Warning: User-level activation encountered an issue, continuing..."
fi

########################################
# 6️⃣ Apply system-level configuration (requires root)
########################################
echo "▶ Running system-level activation (requires root)..."
if ! sudo -E darwin-rebuild switch --flake "$FLAKE_DIR#$CONFIG_NAME"; then
  echo "⚠️ Warning: System-level activation encountered an issue, but continuing..."
fi

########################################
# 7️⃣ Done
########################################
echo ""
echo "✅ macOS setup complete."
echo ""
echo "Next steps:"
echo "• Restart Terminal."
echo "• Sign into App Store for mas/Xcode."
echo "• Use 'darwin-rebuild switch --flake ~/nix#$CONFIG_NAME' to update your system."
