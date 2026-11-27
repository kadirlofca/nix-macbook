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

The Mac updates itself: a daily launchd job (02:00, or on wake) runs
`nix-macbook-update`. It waits for the network, checks there is at least 20 GB
free and that the repo is clean and in step with GitHub, updates every flake
input and switches. A failure shows a notification and leaves
`NIX-UPDATE-FAILED.txt` on the Desktop. Log: `/var/log/auto-update.log`.
Commit or stash your own edits, or the update is skipped.

Versions are not pinned (`flake.lock` is git-ignored). To update right now,
including apps:

```sh
update   # sudo nix-macbook-update --now
```

To apply only your own edits without updating:

```sh
cd ~/Projects/nix-macbook
sudo darwin-rebuild switch --flake .#kadir-macbook
```

## Layout

| File | Owns |
|---|---|
| `flake.nix` | Inputs (rolling: nixpkgs-unstable, nix-darwin and home-manager master), host definition, Homebrew taps |
| `darwin.nix` | System settings (Dock, Finder, menu bar, keyboard), Homebrew casks |
| `home.nix` | Git, zsh, direnv, wallpaper, Zen browser |
| `bootstrap.sh` | One-command setup for a fresh Mac |

## Not managed

Privacy permissions, account sign-ins (App Store, Zen, iCloud), extension
settings such as LeechBlock block lists, Zen pinned tabs, Xcode, and DaVinci
Resolve (it has no Homebrew cask). `homebrew.onActivation.cleanup = "uninstall"`
removes any Homebrew app or formula not declared in `darwin.nix`, but keeps its
data.
