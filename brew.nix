{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    taps = [];

    casks = [
      "whatsapp"
      "zen"
      "microsoft-teams"
      "affinity"
      "docker-desktop"
      "android-studio"
    ];

    masApps = {
      "Xcode" = 497799835;
    };
  };
}
