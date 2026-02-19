{ config, pkgs, ... }:

{
  home.username = "kadirlofca";
  home.homeDirectory = "/Users/kadirlofca";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Kadir Lofca";
        email = "kadirlofca@outlook.com";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
    ignores = [ ".DS_Store" ".env" ".env.*" ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      update = "darwin-rebuild switch --flake ~/nix#kadir-macbook";
    };
  };
}
