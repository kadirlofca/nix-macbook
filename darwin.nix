{ pkgs, ... }:

{
  system.primaryUser = "kadirlofca";

  networking.hostName = "kadir-macbook";
  networking.computerName = "kadir-macbook";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "right";
      tilesize = 64;
      magnification = false;
      show-process-indicators = false;
      showhidden = true;
      minimize-to-application = true;
      mineffect = "genie";
      show-recents = false;
      static-only = true;
      launchanim = false;
      mru-spaces = true;
      autohide-delay = 0.001;
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
      persistent-apps = [];
      persistent-others = [];
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "Flwv";
      FXEnableExtensionChangeWarning = true;
      ShowPathbar = true;
      ShowStatusBar = false;
      _FXSortFoldersFirst = true;
      CreateDesktop = true;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleICUForce24HourTime = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      ApplePressAndHoldEnabled = false;
      "com.apple.swipescrolldirection" = true;
      _HIHideMenuBar = true;
    };

    WindowManager = {
      GloballyEnabled = false;
      EnableStandardClickToShowDesktop = false;
      EnableTilingByEdgeDrag = true;
    };

    trackpad = {
      Clicking = false;
      Dragging = false;
      TrackpadThreeFingerDrag = false;
      TrackpadRightClick = true;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    controlcenter = {
      BatteryShowPercentage = false;
      AirDrop = false;
      Bluetooth = false;
    };
  };

  environment.systemPackages = with pkgs; [
    git
    discord
    zed-editor
    devenv
    direnv
    ollama
  ];

  fonts.packages = with pkgs; [
    google-fonts
  ];

  launchd.user.agents.ollama = {
    serviceConfig = {
      ProgramArguments = [ "${pkgs.ollama}/bin/ollama" "serve" ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/ollama.out.log";
      StandardErrorPath = "/tmp/ollama.err.log";
    };
  };

  imports = [ ./brew.nix ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.enable = false;

  programs.zsh.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  system.stateVersion = 4;
}
