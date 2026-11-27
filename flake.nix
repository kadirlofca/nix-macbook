{
  description = "kadir-macbook: nix-darwin + home-manager + nix-homebrew";

  inputs = {
    # Rolling branches, always the latest. Keep all three on their unstable/master
    # lines together; `update` (see home.nix) refreshes every input before a switch.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-homebrew
                   , homebrew-core, homebrew-cask, zen-browser, ... }: {
    darwinConfigurations."kadir-macbook" = nix-darwin.lib.darwinSystem {
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        { home-manager.sharedModules = [ zen-browser.homeModules.beta ]; }
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
