{ config, ... }:
{
  system.defaults.CustomUserPreferences."net.imput.helium" = {
    RestoreOnStartup = 1;
    DefaultSearchProviderEnabled = true;
    DefaultSearchProviderName = "Google";
    DefaultSearchProviderKeyword = "google.com";
    DefaultSearchProviderSearchURL = "https://www.google.com/search?q={searchTerms}";
    DefaultSearchProviderSuggestURL = "https://www.google.com/complete/search?client=chrome&q={searchTerms}";
  };

  home-manager.users.${config.system.primaryUser} =
    { lib, pkgs, ... }:
    let
      extensions = {
        onepassword = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";
        refined-github = "hlepfoohegkhhmjieoechaddaejaokhf";
        stylex-devtools = "pfcoadoepdjlhhnchklcinajnmmninem";
        minimal-twitter = "pobhoodpcipjmedfenaigbeloiidbflp";
        control-panel-for-twitter = "kpmjjdhbcfebfjgdnpjagcndoelnidfj";
        sponsorblock = "mnjggcdmjocbbbhaepdhchncahnbgone";
      };

      prefs = {
        helium.browser = {
          layout = 2;
          vertical_right_aligned = false;
          centered_location_bar = false;
          minimal_location_bar = false;
          show_progress_bar = false;
          zen_mode = true;
          zen_mode_sidebar_pinned = false;
          zen_mode_top_chrome_pinned = true;
        };
        vertical_tabs.expand_on_hover = false;
      };
    in
    {
      # Helium rewrites Preferences on quit, so merge only while it is closed
      home.activation.heliumPrefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        prefs="$HOME/Library/Application Support/net.imput.helium/Default/Preferences"
        if [ -f "$prefs" ]; then
          if /usr/bin/pgrep -qf 'Helium.app/Contents/MacOS/Helium$'; then
            echo "Helium is running, skipping Helium preferences"
          else
            tmp=$(mktemp)
            ${pkgs.jq}/bin/jq --argjson s ${lib.escapeShellArg (builtins.toJSON prefs)} '. * $s' "$prefs" > "$tmp"
            run mv "$tmp" "$prefs"
          fi
        fi
      '';

      home.file =
        lib.mapAttrs' (
          _: id:
          lib.nameValuePair "Library/Application Support/net.imput.helium/External Extensions/${id}.json" {
            # Helium drops prodversion from update checks, and without it the Web Store answers "noupdate"
            text = builtins.toJSON {
              external_update_url = "https://clients2.google.com/service/update2/crx?prodversion=156.0";
            };
          }
        ) extensions
        // {
          # 1Password does not write this manifest for browsers added in Settings > Browser
          # https://www.1password.community/1password-at-home-31/connect-to-additional-browsers-signed-chromium-10148
          "Library/Application Support/net.imput.helium/NativeMessagingHosts/com.1password.1password.json".text =
            builtins.toJSON {
              name = "com.1password.1password";
              description = "1Password BrowserSupport";
              path = "/Applications/1Password.app/Contents/Library/LoginItems/1Password Browser Helper.app/Contents/MacOS/1Password-BrowserSupport";
              type = "stdio";
              allowed_origins = [ "chrome-extension://${extensions.onepassword}/" ];
            };
        };
    };
}
