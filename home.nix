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

  # Zen is installed by this module (zen-browser-flake), not by a Homebrew cask.
  # Values were read from the profile on the old Mac on 2026-11-27. Pinned tabs
  # are deliberately not declared: they hold personal URLs and session tokens.
  # UNVERIFIED: close Zen before a switch; check option names at the first build.
  programs.zen-browser = {
    enable = true;
    darwin.packageMode = "signed"; # keeps Apple code signature intact

    policies.ExtensionSettings = builtins.mapAttrs (_: slug: {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
      installation_mode = "force_installed";
    }) {
      # Slugs checked against the addons.mozilla.org API by extension ID.
      "jid1-q4sG8pYhq8KGHs@jetpack" = "adblock-for-youtube"; # AdBlocker for YouTube
      "leechblockng@proginosko.com" = "leechblock-ng"; # LeechBlock NG
    };

    profiles.default = {
      id = 0;

      settings = {
        "browser.shell.checkDefaultBrowser" = false;
        "browser.warnOnQuitShortcut" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "findbar.highlightAll" = true;
        "privacy.history.custom" = true;
        "privacy.clearOnShutdown_v2.formdata" = true;
        "sidebar.visibility" = "hide-launcher";
        "zen.glance.enabled" = false;
        "zen.swipe.is-fast-swipe" = false;
        "zen.tabs.show-newtab-vertical" = false;
        "zen.view.compact.enable-at-startup" = true;
        "zen.view.window.scheme" = 0;
      };

      search = {
        force = true;
        default = "ddg";
      };

      mods = [
        "6f11c932-b992-433e-8c80-56a613cc511e" # Left close button
      ];

      # Names for ids 1-4 are Firefox's defaults; the profile only stored
      # their icon and colour.
      containers = {
        Personal = { id = 1; icon = "fingerprint"; color = "blue"; };
        Work = { id = 2; icon = "briefcase"; color = "orange"; };
        Banking = { id = 3; icon = "dollar"; color = "green"; };
        Shopping = { id = 4; icon = "cart"; color = "pink"; };
        DC = { id = 6; icon = "fence"; color = "red"; };
      };

      spaces = {
        Personal = {
          id = "{3f7dc801-b109-4913-b92a-892ebf2c958f}";
          position = 1000;
          icon = "chrome://browser/skin/zen-icons/selectable/star-1.svg";
          container = 1;
          theme = {
            type = "gradient";
            colors = [{
              red = 54;
              green = 54;
              blue = 54;
              algorithm = "floating";
              type = "explicit-black-white";
              lightness = 21;
            }];
            opacity = 0.35;
            texture = 0.25;
          };
        };
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
