{ pkgs, ... }:

{
  networking.hostName = "kadir-macbook";
  networking.computerName = "kadir-macbook";

  security.pam.enableSudoTouchIdAuth = true;

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
      autohide-delay = 1.5;
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
      "com.apple.mouse.tapBehavior" = null;
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
      TrackpadThreeFingerTapGesture = null;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    controlcenter = {
      BatteryShowPercentage = false;
      AirDrop = false;
      Bluetooth = false;
    };
  };

  system.activationScripts.postUserActivation.text = ''
    killall Dock
    osascript -e 'tell application "Finder" to set desktop picture to POSIX file "${./wallpaper.jpg}"'
  '';

  environment.systemPackages = [
    pkgs.git
    pkgs.discord
    pkgs.zed-editor
    pkgs.android-studio
  ];

  fonts.packages = with pkgs; [
    google-fonts
  ];

  imports = [ ./brew.nix ];

  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.allowUnfree = true;

  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.settings.experimental-features = "nix-command flakes";

  programs.zsh.enable = true;

  system.stateVersion = 4;
}
