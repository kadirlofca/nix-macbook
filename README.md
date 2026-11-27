# nix-macbook

Reproducible macOS setup for an Apple Silicon MacBook: nix-darwin, home-manager
and nix-homebrew on Determinate Nix.

> **Status: untested.** Nothing here has been built or run yet. Expect to fix
> option names on the first `darwin-rebuild build`.

## Fresh Mac

Create the account with the short name `kadirlofca` in Setup Assistant, then run:

```sh
curl -fsSL https://raw.githubusercontent.com/kadirlofca/nix-macbook/main/bootstrap.sh | bash
```

It installs the Xcode command line tools and Determinate Nix, clones this repo
to `~/Projects/nix-macbook`, and runs the first `darwin-rebuild switch`.

## Day to day

```sh
cd ~/Projects/nix-macbook
sudo darwin-rebuild switch --flake .#kadir-macbook
```

## Layout

| File | Owns |
|---|---|
| `flake.nix` | Inputs (26.05 release branches), host definition, Homebrew taps |
| `darwin.nix` | System settings (Dock, Finder, menu bar, keyboard), Homebrew casks |
| `home.nix` | Git, zsh, direnv, wallpaper, Zen browser |
| `bootstrap.sh` | One-command setup for a fresh Mac |

## Not managed

Privacy permissions, account sign-ins (App Store, Zen, iCloud), extension
settings such as LeechBlock block lists, Zen pinned tabs, and Xcode.
`homebrew.onActivation.cleanup = "zap"` removes any Homebrew app not declared
in `darwin.nix`.
