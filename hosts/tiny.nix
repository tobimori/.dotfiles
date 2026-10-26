{ pkgs, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "tiny";
  networking.computerName = "tiny";

  # Determinate Nix manages the Nix daemon and /etc/nix
  nix.enable = false;

  system.primaryUser = "tm";
  users.users.tm.home = "/Users/tm";

  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  environment.systemPackages = with pkgs; [
    btop
    fd
    gh
    git
    jq
    micro
    mise
    ripgrep
    starship
  ];

  nix-homebrew = {
    enable = true;
    user = "tm";
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    brews = [
      "defaultbrowser"
      "displayplacer"
      "duti"
    ];
    casks = [
      "1password"
      "1password-cli"
      "beeper"
      "eurkey-next"
      "ghostty"
      "helium-browser"
      "mimestream"
      "tailscale-app"
      "yubico-authenticator"
    ];
  };

  launchd.user.agents.tailscale.serviceConfig = {
    ProgramArguments = [ "/usr/bin/open" "-a" "/Applications/Tailscale.app" ];
    RunAtLoad = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.4;
      tilesize = 48;
      show-recents = false;
      minimize-to-application = true;
      mru-spaces = false;
      persistent-apps = [
        "/Applications/Helium.app"
        "/Applications/Mimestream.app"
        "/Applications/Ghostty.app"
        "/Applications/Beeper Desktop.app"
      ];
      persistent-others = [ ];
    };
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      FXDefaultSearchScope = "SCcf";
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticInlinePredictionEnabled = false;
    };
    screencapture.location = "~/Pictures/Screenshots";
    CustomUserPreferences.NSGlobalDomain.WebAutomaticSpellingCorrectionEnabled = false;
    CustomUserPreferences."net.imput.helium" = {
      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderName = "Google";
      DefaultSearchProviderKeyword = "google.com";
      DefaultSearchProviderSearchURL = "https://www.google.com/search?q={searchTerms}";
      DefaultSearchProviderSuggestURL = "https://www.google.com/complete/search?client=chrome&q={searchTerms}";
    };
    CustomUserPreferences."com.apple.HIToolbox" =
      let
        eurkey = {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = -31468;
          "KeyboardLayout Name" = "EurKEY Next";
        };
      in
      {
        AppleFnUsageType = 1;
        AppleCurrentKeyboardLayoutInputSourceID = "de.felixfoertsch.keyboardlayout.EurKEY-Next.eurkeynext";
        AppleSelectedInputSources = [ eurkey ];
        AppleEnabledInputSources = [
          eurkey
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 3;
            "KeyboardLayout Name" = "German";
          }
          {
            "Bundle ID" = "com.apple.CharacterPaletteIM";
            InputSourceKind = "Non Keyboard Input Method";
          }
        ];
      };
  };

  system.activationScripts.postActivation.text = ''
    rm -rf \
      "/Applications/GarageBand.app" \
      "/Applications/iMovie.app" \
      "/Applications/Keynote Creator Studio.app" \
      "/Applications/Numbers Creator Studio.app" \
      "/Applications/Pages Creator Studio.app" \
      "/Library/Application Support/GarageBand" \
      "/Library/Application Support/Logic" \
      "/Library/Audio/Apple Loops"

    if [ "$(dscl . -read /Users/tm UserShell | awk '{print $2}')" != /run/current-system/sw/bin/fish ]; then
      chsh -s /run/current-system/sw/bin/fish tm
    fi

    launchctl asuser "$(id -u tm)" sudo -u tm /opt/homebrew/bin/displayplacer \
      "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1637x1024 scaling:on" || true

    launchctl asuser "$(id -u tm)" sudo -u tm /opt/homebrew/bin/defaultbrowser helium || true
    launchctl asuser "$(id -u tm)" sudo -u tm /opt/homebrew/bin/duti -s com.mimestream.Mimestream mailto || true
  '';

  system.stateVersion = 6;
}
