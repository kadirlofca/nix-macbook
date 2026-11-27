{ pkgs, ... }:
let
  # The unattended updater. It lives in the system profile and the launchd job
  # points at its fixed path, so the job's plist never changes: a switch can no
  # longer reload (and kill) the job that is running it. UNTESTED.
  nixMacbookUpdate = pkgs.writeShellScriptBin "nix-macbook-update" ''
    export PATH=/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin
    user=kadirlofca
    repo=/Users/kadirlofca/Projects/nix-macbook
    stamp=/var/db/auto-update.last-success
    note=/Users/kadirlofca/Desktop/NIX-UPDATE-FAILED.txt

    # One run at a time (the daily job, `update`, and the weekly cleanup share it).
    if [ "$NIX_MACBOOK_LOCKED" != 1 ]; then
      NIX_MACBOOK_LOCKED=1 /usr/bin/lockf -t 0 /var/run/nix-macbook.lock "$0" "$@"
      rc=$?
      [ "$rc" = 75 ] && echo "another nix-macbook run is already in progress"
      exit $rc
    fi

    # Skip if a run succeeded in the last 20 h, unless asked with --now.
    if [ "$1" != "--now" ] && [ -f "$stamp" ] && [ $(( $(date +%s) - $(cat "$stamp") )) -lt 72000 ]; then
      exit 0
    fi
    echo "=== $(date) ==="

    as_user() { /usr/bin/sudo -u $user -H env PATH="$PATH" "$@"; }

    # Notification (best effort) plus a visible file, in case notifications are off.
    fail() {
      echo "FAILED: $1"
      /bin/launchctl asuser "$(id -u $user)" /usr/bin/sudo -u $user \
        /usr/bin/osascript -e "display notification \"$1\" with title \"nix-macbook\"" || true
      printf '%s\n%s\nLog: /var/log/auto-update.log\n' "$1" "$(date)" > "$note"
      chown $user "$note" 2>/dev/null || true
      exit 1
    }

    # Wait for the network (up to 5 min); a quiet exit retries at the next trigger.
    n=0
    until /usr/bin/curl -sfI -m 5 https://github.com >/dev/null; do
      n=$((n + 1))
      if [ "$n" -ge 30 ]; then echo "no network, will retry at the next trigger"; exit 1; fi
      sleep 10
    done

    # Refuse to switch with less than 20 GB free; a full disk mid-switch can leave
    # the system half-activated.
    free_gb() { df -k /System/Volumes/Data | awk 'NR==2 { print int($4 / 1048576) }'; }
    if [ "$(free_gb)" -lt 20 ]; then
      nix-collect-garbage --delete-older-than 30d
      [ "$(free_gb)" -ge 20 ] || fail "Less than 20 GB free, update skipped."
    fi

    cd "$repo" || fail "Repo not found at $repo."

    # Never build a half-edited or diverged repo.
    as_user git fetch --quiet || fail "git fetch failed."
    if [ -n "$(as_user git status --porcelain)" ]; then
      fail "Repo has uncommitted changes, update skipped."
    fi
    if as_user git rev-parse --verify --quiet '@{u}' >/dev/null; then
      if [ "$(as_user git rev-list --count 'HEAD..@{u}')" != 0 ]; then
        as_user git merge --ff-only '@{u}' || fail "Repo diverged from origin, update skipped."
      fi
    fi

    # Update inputs as the repo owner so flake.lock stays user-owned.
    as_user nix flake update || fail "nix flake update failed."

    # path: so the (git-ignored) flake.lock is the one that gets built.
    if darwin-rebuild switch --flake "path:$repo#kadir-macbook"; then
      chown $user "$repo/flake.lock" 2>/dev/null || true
      date +%s > "$stamp"
      rm -f "$note"
      echo "update ok"
    else
      chown $user "$repo/flake.lock" 2>/dev/null || true
      fail "Update failed to build or switch."
    fi
  '';
in
{
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

  environment.systemPackages = [ nixMacbookUpdate ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      # Upgrades declared formulae/casks that are outdated. Most of the casks below
      # update themselves, so this mostly applies to the rest.
      upgrade = true;
      # Removes undeclared formulae and casks but keeps their data and settings.
      # "zap" would also delete app data (e.g. Docker's images) with no prompt.
      cleanup = "uninstall";
    };
    brews = [ ];
    casks = [
      "docker-desktop"
      "affinity"
      "blender"
      "discord"
      "whatsapp"
      "obsidian"
      "fluidvoice" # offline speech-to-text dictation
      "yubico-authenticator"
      "claude-code"
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
      ShowStatusBar = false;
      FXPreferredViewStyle = "Nlsv"; # list view
      _FXSortFoldersFirst = true;
      FXEnableExtensionChangeWarning = true;
      FXRemoveOldTrashItems = true; # empty Trash after 30 days
      # No drive icons on the desktop.
      ShowHardDrivesOnDesktop = false;
      ShowExternalHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
      ShowMountedServersOnDesktop = false;
    };
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
      _HIHideMenuBar = true; # menu bar auto-hide; also see AutoHideMenuBarOption

      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleICUForce24HourTime = false; # 12-hour clock

      # Developer style: no automatic text changes.
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticInlinePredictionEnabled = false;

      "com.apple.swipescrolldirection" = true; # natural scrolling
      "com.apple.trackpad.scaling" = 2.0; # tracking speed
    };

    trackpad = {
      Clicking = false; # tap to click off
      TrackpadRightClick = true; # two-finger click
      TrackpadThreeFingerDrag = false;
    };

    WindowManager = {
      GloballyEnabled = false; # Stage Manager off
      EnableStandardClickToShowDesktop = false;
      EnableTiledWindowMargins = false;
      EnableTilingByEdgeDrag = true;
      AppWindowGroupingBehavior = true;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
  };

  networking.applicationFirewall.enable = true;

  # Matches this Mac: display and computer sleep after 1 minute. The 02:00 updater
  # therefore mostly runs on wake.
  power.sleep = {
    computer = 1;
    display = 1;
  };

  # Self-updating: daily at 02:00. If the Mac was asleep, launchd runs it on wake;
  # if it was off, the next day's run catches up. The work is in nix-macbook-update
  # above (network wait, repo checks, disk check, flake update, switch, failure
  # notification plus a note on the Desktop). The job's definition is fixed on
  # purpose. No RunAtLoad: a switch that reloaded it would start a second switch.
  launchd.daemons.auto-update = {
    command = "/run/current-system/sw/bin/nix-macbook-update";
    serviceConfig = {
      StartCalendarInterval = [{ Hour = 2; Minute = 0; }];
      StandardOutPath = "/var/log/auto-update.log";
      StandardErrorPath = "/var/log/auto-update.log";
    };
  };

  # Weekly cleanup, Sunday 03:00 (on wake if asleep). nix-darwin's nix.gc needs
  # nix.enable, which is off for Determinate. Waits (up to 1 h) for a running update.
  # Deletes generations older than 30 days for root and for your user (home-manager
  # keeps its profile under ~/.local/state), collects unreferenced store paths,
  # hard-links duplicates, and clears Homebrew's cache. Project dev shells stay
  # while their project folder exists.
  launchd.daemons.nix-gc = {
    script = ''
      /usr/bin/lockf -t 3600 /var/run/nix-macbook.lock /bin/sh -c '
        nix=/nix/var/nix/profiles/default/bin
        $nix/nix-collect-garbage --delete-older-than 30d
        /usr/bin/sudo -u kadirlofca -H $nix/nix-collect-garbage --delete-older-than 30d
        $nix/nix store optimise
        /usr/bin/sudo -u kadirlofca -H /opt/homebrew/bin/brew cleanup --prune=all
      '
    '';
    serviceConfig = {
      StartCalendarInterval = [{ Weekday = 0; Hour = 3; Minute = 0; }];
      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
    };
  };

  # FluidVoice is a login item on this Mac; there is no declarative login-item
  # option, so a user agent opens it at login. UNTESTED.
  launchd.user.agents.fluidvoice-login = {
    command = "/usr/bin/open -a FluidVoice";
    serviceConfig.RunAtLoad = true;
  };

  # Rotate the two logs. UNVERIFIED: newsyslog line format (name mode count size when flags).
  environment.etc."newsyslog.d/nix-macbook.conf".text = ''
    /var/log/auto-update.log 644 5 1000 * J
    /var/log/nix-gc.log 644 5 1000 * J
  '';

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    overwriteBackup = true; # a stale .backup must not abort every nightly switch
    users.kadirlofca = import ./home.nix;
  };
}
