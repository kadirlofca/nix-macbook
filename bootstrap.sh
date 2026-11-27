#!/usr/bin/env bash
# Bootstrap a fresh Apple Silicon Mac from this repo.
# UNTESTED: run `darwin-rebuild build` and a macOS VM test before trusting it.
#
#   curl -fsSL https://raw.githubusercontent.com/kadirlofca/nix-macbook/main/bootstrap.sh | bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/kadirlofca/nix-macbook.git}"
REPO_DIR="${REPO_DIR:-$HOME/Projects/nix-macbook}"
HOST="kadir-macbook"
EXPECTED_USER="kadirlofca"
NIX_BIN="/nix/var/nix/profiles/default/bin"

say() { printf '\n==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = Darwin ] || die "this is for macOS"
[ "$(uname -m)" = arm64 ] || die "Apple Silicon only (nixpkgs 26.05 dropped Intel Macs)"
[ "$(id -u)" -ne 0 ] || die "run as your normal user, not root"
[ "$(id -un)" = "$EXPECTED_USER" ] || die "the account name must be '$EXPECTED_USER' (is '$(id -un)')"
[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 15 ] || die "macOS 15 or later is required"

say "1/4 Xcode command line tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  echo "Finish the installer dialog; waiting (up to 30 min)..."
  waited=0
  until xcode-select -p >/dev/null 2>&1; do
    [ "$waited" -lt 1800 ] || die "command line tools not installed; install them and re-run"
    sleep 5; waited=$((waited + 5))
  done
fi

say "2/4 Determinate Nix"
if [ ! -x "$NIX_BIN/nix" ]; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
fi
export PATH="$NIX_BIN:$PATH"

say "3/4 Config repo -> $REPO_DIR"
if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" pull --ff-only
else
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone "$REPO_URL" "$REPO_DIR"
fi

# Create flake.lock as the user. If root created it first, the daily updater
# (which runs `nix flake update` as the user) could not overwrite it.
cd "$REPO_DIR"
nix flake lock

say "4/4 First switch (nix-darwin + home-manager + Homebrew)"
# nix-darwin moves the stock /etc/zshrc and /etc/bashrc aside itself.
# path: so the git-ignored flake.lock is the one that gets built.
sudo "$NIX_BIN/nix" run nix-darwin/master#darwin-rebuild -- \
  switch --flake "path:$REPO_DIR#$HOST"
sudo chown "$EXPECTED_USER" "$REPO_DIR/flake.lock" || true

cat <<'EOF'

Done. Open a new terminal window so the Nix shell hook loads.

Still manual:
  - Privacy permissions (e.g. FluidVoice: Microphone + Accessibility)
  - Sign in to Zen, the App Store, iCloud and other accounts
  - Re-enter LeechBlock NG's block lists
  - Install Xcode from the App Store and DaVinci Resolve from Blackmagic's site
    if you need them (neither is managed here)
EOF
