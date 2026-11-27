{
  description = "kadir-macbook: nix-darwin + home-manager + nix-homebrew";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-homebrew
                   , homebrew-core, homebrew-cask, ... }: {
    darwinConfigurations."kadir-macbook" = nix-darwin.lib.darwinSystem {
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        ({ config, ... }: {
          nix-homebrew = {
            enable = true;
            user = "kadirlofca";
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };
            mutableTaps = false;
          };
          # keep nix-darwin's tap list aligned with nix-homebrew
          homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
        })
      ];
    };
  };
}
