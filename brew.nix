{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    taps = [
      "homebrew/services"
    ];

    casks = [
      "whatsapp"
      "zen"
      "microsoft-teams"
      "affinity"
      "davinci-resolve"
      "docker"
    ];

    masApps = {
      "Xcode" = 497799835;
    };
  };
}
