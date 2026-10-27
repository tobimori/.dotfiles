{
  asUser,
  config,
  lib,
  ...
}:
let
  user = config.system.primaryUser;
in
{
  homebrew = {
    brews = [
      "defaultbrowser"
      "duti"
    ];
    casks = [
      "1password"
      "1password-cli"
      "beeper"
      "cleanshot"
      "coconutbattery"
      "ghostty"
      "handy"
      "helium-browser"
      "mimestream"
      "t3-code@nightly"
      "tailscale-app"
      "vicinae"
      "yubico-authenticator"
      "zed"
    ];
  };

  launchd.user.agents =
    lib.mapAttrs
      (_: app: {
        serviceConfig = {
          ProgramArguments = [
            "/usr/bin/open"
            "-a"
            "/Applications/${app}.app"
          ];
          RunAtLoad = true;
        };
      })
      {
        tailscale = "Tailscale";
        cleanshot = "CleanShot X";
        vicinae = "Vicinae";
      };

  system.defaults.CustomUserPreferences = {
    "pl.maketheweb.cleanshotx" = {
      analyticsAllowed = false;
      captureWithoutDesktopIcons = true;
      popupSize = 2;
      afterScreenshotActions = [
        0
        1
      ];
      afterVideoActions = [
        0
        1
      ];
      playSounds = false;
      videoFPS = 60;
      maxRecordingResolution = 3;
      SUEnableAutomaticChecks = true;
      SUAutomaticallyUpdate = true;
    };
    "io.tailscale.ipn.macsys" = {
      SUEnableAutomaticChecks = true;
      SUAutomaticallyUpdate = true;
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

    ${asUser} /opt/homebrew/bin/defaultbrowser helium || true
    ${asUser} /opt/homebrew/bin/duti -s com.mimestream.Mimestream mailto || true
    sudo -u ${user} /Applications/Tailscale.app/Contents/MacOS/Tailscale set --auto-update=true || true

    # Domains of sandboxed apps need Full Disk Access, which a Tailscale SSH session
    # lacks, so write them here instead of in system.defaults, where a failure aborts
    while read -r domain key type value; do
      sudo -u ${user} defaults write "$domain" "$key" "-$type" "$value" 2>/dev/null \
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
    pb=/usr/libexec/PlistBuddy
    ncprefs=$(mktemp)
    chown ${user} "$ncprefs"
    sudo -u ${user} defaults export com.apple.ncprefs "$ncprefs"
    i=0
    while bundle=$($pb -c "Print :apps:$i:bundle-id" "$ncprefs" 2>/dev/null); do
      if [ "$bundle" = com.apple.MobileSMS ]; then
        flags=$($pb -c "Print :apps:$i:flags" "$ncprefs")
        if [ $((flags & 4)) -ne 0 ]; then
          $pb -c "Set :apps:$i:flags $((flags & ~4))" "$ncprefs"
          sudo -u ${user} defaults import com.apple.ncprefs "$ncprefs"
          killall usernoted NotificationCenter 2>/dev/null || true
        fi
      fi
      i=$((i + 1))
    done
    rm -f "$ncprefs"

    # Free the screenshot shortcuts for CleanShot X, and ⌘Space for Vicinae by moving
    # Spotlight (64) to ⌃Space, which input source switching (60) gives up.
    # The parameters must be integers; defaults -dict-add stores strings, which macOS ignores
    pb=/usr/libexec/PlistBuddy
    hotkeys=$(mktemp)
    chown ${user} "$hotkeys"
    sudo -u ${user} defaults export com.apple.symbolichotkeys "$hotkeys"
    while read -r id enabled key code mods; do
      e=":AppleSymbolicHotKeys:$id"
      $pb -c "Delete $e" "$hotkeys" 2>/dev/null || true
      $pb -c "Add $e dict" -c "Add $e:enabled bool $enabled" -c "Add $e:value dict" \
        -c "Add $e:value:type string standard" -c "Add $e:value:parameters array" \
        -c "Add $e:value:parameters:0 integer $key" -c "Add $e:value:parameters:1 integer $code" \
        -c "Add $e:value:parameters:2 integer $mods" "$hotkeys"
    done <<'EOF'
    28 false 51 20 1179648
    29 false 51 20 1441792
    30 false 52 21 1179648
    31 false 52 21 1441792
    184 false 53 23 1179648
    60 false 32 49 262144
    64 true 32 49 262144
    EOF
    sudo -u ${user} defaults import com.apple.symbolichotkeys "$hotkeys"
    rm -f "$hotkeys"
    ${asUser} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  home-manager.users.${user} =
    {
      lib,
      link,
      pkgs,
      ...
    }:
    {
      xdg.configFile = {
        "ghostty/config".source = link "config/ghostty/config";
        # Vicinae replaces settings.json on every save, so it owns that file and imports this one
        "vicinae/dotfiles.json".source = link "config/vicinae/dotfiles.json";
      };

      home.activation.vicinaeImport = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        settings="$HOME/.config/vicinae/settings.json"
        if ! grep -qs '"./dotfiles.json"' "$settings"; then
          run mkdir -p "$(dirname "$settings")"
          tmp=$(mktemp)
          { grep -vs '^ *//' "$settings" || echo '{}'; } \
            | ${pkgs.jq}/bin/jq '.imports = ((.imports // []) + ["./dotfiles.json"])' > "$tmp"
          run mv "$tmp" "$settings"
        fi
      '';

      home.file.".ssh/config".text = ''
        Host *
          IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      '';
    };
}
