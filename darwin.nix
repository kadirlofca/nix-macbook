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

  # Keeps the Nix store from growing. nix-darwin's nix.gc needs nix.enable, which
  # is off for Determinate, so this runs the commands from a launchd job instead.
  # Weekly, Sunday 03:00 (runs on wake if the Mac was asleep). Deletes generations
  # older than 30 days, collects unreferenced store paths, then hard-links
  # duplicate files. The current generation is never deleted.
  launchd.daemons.nix-gc = {
    script = ''
      /nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 30d
      /nix/var/nix/profiles/default/bin/nix store optimise
    '';
    serviceConfig = {
      StartCalendarInterval = [{ Weekday = 0; Hour = 3; Minute = 0; }];
      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
    };
  };

  # Homebrew's download cache and old versions also grow. Runs as your user.
  launchd.user.agents.brew-cleanup = {
    command = "/opt/homebrew/bin/brew cleanup --prune=all";
    serviceConfig = {
      StartCalendarInterval = [{ Weekday = 0; Hour = 3; Minute = 30; }];
      StandardOutPath = "/tmp/brew-cleanup.log";
      StandardErrorPath = "/tmp/brew-cleanup.log";
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.kadirlofca = import ./home.nix;
  };
}
