{ lib, pkgs, ... }:
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
    (writeShellScriptBin "tailscale-ssh" ''
      exec ${tailscale}/bin/tailscale --socket=/var/run/tailscale-ssh.sock "$@"
    '')
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
      "cleanshot"
      "eurkey-next"
      "ghostty"
      "handy"
      "helium-browser"
      "mimestream"
      "t3-code@nightly"
      "tailscale-app"
      "yubico-authenticator"
      "zed"
    ];
  };

  launchd.user.agents = lib.mapAttrs (_: app: {
    serviceConfig = {
      ProgramArguments = [ "/usr/bin/open" "-a" "/Applications/${app}.app" ];
      RunAtLoad = true;
    };
  }) {
    tailscale = "Tailscale";
    cleanshot = "CleanShot X";
  };

  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = true;
    allowSigned = true;
    allowSignedApp = true;
  };

  services.openssh.enable = false;

  # Second, userspace-only tailscaled next to the Tailscale app, because only the
  # open source variant can be a Tailscale SSH server on macOS
  # https://tailscale.com/docs/concepts/macos-variants
  # It runs from a stable path because Full Disk Access is granted per binary path
  system.activationScripts.preActivation.text = ''
    # bin/tailscaled is a shell wrapper that only adds lsof to PATH
    if ! cmp -s ${pkgs.tailscale}/bin/.tailscaled-wrapped /usr/local/libexec/tailscaled-ssh; then
      install -d /usr/local/libexec
      install -m 755 ${pkgs.tailscale}/bin/.tailscaled-wrapped /usr/local/libexec/tailscaled-ssh
      touch /var/run/tailscaled-ssh.updated
    fi
  '';
  launchd.daemons.tailscaled-ssh.serviceConfig = {
    ProgramArguments = [
      "/usr/local/libexec/tailscaled-ssh"
      "--tun=userspace-networking"
      "--statedir=/var/lib/tailscale-ssh"
      "--socket=/var/run/tailscale-ssh.sock"
      "--port=0"
    ];
    EnvironmentVariables.PATH = "${pkgs.lsof}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
    RunAtLoad = true;
    KeepAlive = true;
    StandardErrorPath = "/var/log/tailscaled-ssh.log";
  };

  # SSH and Screen Sharing only from the tailnet. A sub-anchor of com.apple is
  # evaluated by the stock /etc/pf.conf, which macOS updates overwrite
  launchd.daemons.pf-tailscale-only.serviceConfig = {
    ProgramArguments = [
      "/bin/sh"
      "-c"
      "/sbin/pfctl -E; /sbin/pfctl -f /etc/pf.conf; /sbin/pfctl -a com.apple/tailscale-only -f ${pkgs.writeText "tailscale-only.pf" ''
        ports = "{ 22, 3283, 5900, 5901, 5902 }"
        pass in quick on lo0 all
        pass in quick inet proto { tcp, udp } from 100.64.0.0/10 to any port $ports
        pass in quick inet6 proto { tcp, udp } from fd7a:115c:a1e0::/48 to any port $ports
        block in quick proto { tcp, udp } from any to any port $ports
      ''}"
    ];
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
        "/Applications/Mimestream.app"
        "/Applications/Helium.app"
        "/Applications/Beeper Desktop.app"
        "/Applications/T3 Code (Nightly).app"
        "/Applications/Ghostty.app"
      ];
      persistent-others = [ ];
    };
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      AppleShowAllFiles = true;
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
    CustomUserPreferences."com.apple.assistant.support"."Assistant Enabled" = false;
    CustomUserPreferences."com.apple.Siri".StatusMenuVisible = false;
    CustomUserPreferences."pl.maketheweb.cleanshotx" = {
      analyticsAllowed = false;
      captureWithoutDesktopIcons = true;
      popupSize = 2;
      afterScreenshotActions = [ 0 1 ];
      afterVideoActions = [ 0 1 ];
      playSounds = false;
      videoFPS = 60;
      maxRecordingResolution = 3;
      SUEnableAutomaticChecks = true;
      SUAutomaticallyUpdate = true;
    };
    CustomUserPreferences."io.tailscale.ipn.macsys" = {
      SUEnableAutomaticChecks = true;
      SUAutomaticallyUpdate = true;
    };
    CustomUserPreferences."net.imput.helium" = {
      RestoreOnStartup = 1;
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
    if [ -e /var/run/tailscaled-ssh.updated ]; then
      rm /var/run/tailscaled-ssh.updated
      launchctl kickstart -k system/org.nixos.tailscaled-ssh || true
    fi

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
    sudo -u tm /Applications/Tailscale.app/Contents/MacOS/Tailscale set --auto-update=true || true

    # Free the screenshot shortcuts for CleanShot X. The parameters must be integers;
    # defaults -dict-add would store them as strings, which macOS ignores
    pb=/usr/libexec/PlistBuddy
    hotkeys=$(mktemp)
    chown tm "$hotkeys"
    sudo -u tm defaults export com.apple.symbolichotkeys "$hotkeys"
    while read -r id key code mods; do
      e=":AppleSymbolicHotKeys:$id"
      $pb -c "Delete $e" "$hotkeys" 2>/dev/null || true
      $pb -c "Add $e dict" -c "Add $e:enabled bool false" -c "Add $e:value dict" \
        -c "Add $e:value:type string standard" -c "Add $e:value:parameters array" \
        -c "Add $e:value:parameters:0 integer $key" -c "Add $e:value:parameters:1 integer $code" \
        -c "Add $e:value:parameters:2 integer $mods" "$hotkeys"
    done <<'EOF'
    28 51 20 1179648
    29 51 20 1441792
    30 52 21 1179648
    31 52 21 1441792
    184 53 23 1179648
    EOF
    sudo -u tm defaults import com.apple.symbolichotkeys "$hotkeys"
    rm -f "$hotkeys"
    launchctl asuser "$(id -u tm)" sudo -u tm \
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

    # Domains of sandboxed apps need Full Disk Access, which a Tailscale SSH session
    # lacks, so write them here instead of in system.defaults, where a failure aborts
    while read -r domain key type value; do
      sudo -u tm defaults write "$domain" "$key" "-$type" "$value" 2>/dev/null \
        || echo "warning: could not write $domain $key (needs Full Disk Access)"
    done <<'EOF'
    com.apple.MobileSMS NSAutomaticSpellingCorrectionEnabled bool false
    com.apple.MobileSMS WebAutomaticSpellingCorrectionEnabled bool false
    com.apple.MobileSMS PlaySoundsKey bool false
    com.mimestream.Mimestream SUEnableAutomaticChecks bool true
    com.mimestream.Mimestream SUAutomaticallyUpdate bool true
    EOF

    # Clear the sound bit (1 << 2) of the Messages notification flags
    # https://github.com/bilousoleksandr/ncmanager#flags
    ncprefs=$(mktemp)
    chown tm "$ncprefs"
    sudo -u tm defaults export com.apple.ncprefs "$ncprefs"
    i=0
    while bundle=$($pb -c "Print :apps:$i:bundle-id" "$ncprefs" 2>/dev/null); do
      if [ "$bundle" = com.apple.MobileSMS ]; then
        flags=$($pb -c "Print :apps:$i:flags" "$ncprefs")
        if [ $((flags & 4)) -ne 0 ]; then
          $pb -c "Set :apps:$i:flags $((flags & ~4))" "$ncprefs"
          sudo -u tm defaults import com.apple.ncprefs "$ncprefs"
          killall usernoted NotificationCenter 2>/dev/null || true
        fi
      fi
      i=$((i + 1))
    done
    rm -f "$ncprefs"
  '';

  system.stateVersion = 6;
}
