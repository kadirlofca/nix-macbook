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
      "docker-desktop"
      "affinity"
      "blender"
      "davinci-resolve"
      "discord"
      "whatsapp"
      "obsidian"
      "fluidvoice" # offline speech-to-text dictation
    ];
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
    # Menu bar, mirroring this Mac's preferences read on 2026-11-27.
    menuExtraClock = {
      IsAnalog = false;
      ShowDayOfWeek = true;
      ShowDate = 0; # 0 = when space allows
      ShowSeconds = false;
      ShowAMPM = false;
      FlashDateSeparators = false;
    };
    controlcenter = {
      BatteryShowPercentage = false;
      Bluetooth = false;
      AirDrop = false;
    };
    CustomUserPreferences."com.apple.Siri".StatusMenuVisible = false;
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      ShowPathbar = true;
    };
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
      _HIHideMenuBar = true; # menu bar auto-hide; also see AutoHideMenuBarOption
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.kadirlofca = import ./home.nix;
  };
}
