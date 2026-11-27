{ pkgs, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = "kadirlofca";
  system.stateVersion = 6;

  # Determinate Nix owns the install, the daemon and /etc/nix settings
  nix.enable = false;

  networking.hostName = "kadir-macbook";
  networking.localHostName = "kadir-macbook";

  users.users.kadirlofca = {
    name = "kadirlofca";
    home = "/Users/kadirlofca";
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };
    brews = [ ];
    casks = [
      "zen"
      "docker-desktop"
      "affinity"
      "blender"
      "davinci-resolve"
      "discord"
      "whatsapp"
      "obsidian"
    ];
    masApps = {
      "Xcode" = 497799835;
    };
  };

  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.001;
      orientation = "right";
      tilesize = 73;
      largesize = 16;
      magnification = false;
      mineffect = "genie";
      minimize-to-application = true;
      launchanim = false;
      show-recents = false;
      show-process-indicators = false;
      showhidden = true;
      static-only = true;
      mru-spaces = true;
      expose-group-apps = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      ShowPathbar = true;
    };
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.kadirlofca = import ./home.nix;
  };
}
