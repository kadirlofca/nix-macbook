{ pkgs, ... }: {
  home.stateVersion = "26.05";

  # Toolchains live in per-project flakes (loaded by direnv), not here.
  home.packages = [ ];

  # direnv's hooks need home-manager to manage the shell
  programs.zsh.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "Kadir Lofca";
      email = "kadirlofca@outlook.com";
    };
    ignores = [ ".DS_Store" ];
  };

  # UNVERIFIED: programs.desktoppr is on home-manager master; check it exists in
  # release-26.05 at the first `darwin-rebuild build`. Uses Apple's built-in black
  # image because the module has no true solid-color mode.
  programs.desktoppr = {
    enable = true;
    picture = "/System/Library/Desktop Pictures/Solid Colors/Black.png";
    scale = "fill";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
