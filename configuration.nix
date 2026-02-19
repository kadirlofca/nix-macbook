{ pkgs, ... }:

{
  networking.hostName = "kadir-macbook";
  networking.computerName = "kadir-macbook";

  system.primaryUser = "kadirlofca";

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
      EnableTiledWindowMargins = false;
    };

    trackpad = {
      Clicking = false;
      Dragging = false;
      TrackpadThreeFingerDrag = false;
      TrackpadRightClick = true;
      TrackpadThreeFingerTapGesture = 0;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    controlcenter = {
      BatteryShowPercentage = false;
      AirDrop = false;
      Bluetooth = false;
    };
  };

  system.activationScripts.postActivation.text = ''
    # Set the wallpaper
    # We must use sudo -u to run this as the primary user because activation runs as root
    sudo -u kadirlofca /usr/bin/osascript -e 'tell application "Finder" to set desktop picture to POSIX file "${./wallpaper.jpg}"'

    # Restart the Dock to apply changes
    killall Dock
  '';

  environment.systemPackages = [
    pkgs.git
    pkgs.discord
    pkgs.zed-editor
    pkgs.ghostty
    pkgs.android-studio
  ];

  fonts.packages = with pkgs; [
    google-fonts
  ];

  imports = [ ./brew.nix ];

  nix.package = pkgs.nix;
  nix.settings.experimental-features = "nix-command flakes";

  programs.zsh.enable = true;

  system.stateVersion = 4;
}
