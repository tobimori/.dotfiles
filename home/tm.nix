{ config, lib, pkgs, ... }:
let
  # Absolute string path, so links point into the checkout and stay writable
  # https://github.com/nix-community/home-manager/issues/2085
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";

  heliumExtensions = {
    onepassword = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";
    refined-github = "hlepfoohegkhhmjieoechaddaejaokhf";
    stylex-devtools = "pfcoadoepdjlhhnchklcinajnmmninem";
    minimal-twitter = "pobhoodpcipjmedfenaigbeloiidbflp";
    control-panel-for-twitter = "kpmjjdhbcfebfjgdnpjagcndoelnidfj";
  };

  heliumPrefs = {
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
  home.stateVersion = "26.05";

  xdg.configFile = {
    "fish/config.fish".source = link "config/fish/config.fish";
    "git/config".source = link "config/git/config";
    "gh/config.yml".source = link "config/gh/config.yml";
    "ghostty/config".source = link "config/ghostty/config";
    "mise/config.toml".source = link "config/mise/config.toml";
  };

  # Helium rewrites Preferences on quit, so merge only while it is closed
  home.activation.heliumPrefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    prefs="$HOME/Library/Application Support/net.imput.helium/Default/Preferences"
    if [ -f "$prefs" ]; then
      if /usr/bin/pgrep -qf 'Helium.app/Contents/MacOS/Helium$'; then
        echo "Helium is running, skipping Helium preferences"
      else
        tmp=$(mktemp)
        ${pkgs.jq}/bin/jq --argjson s ${lib.escapeShellArg (builtins.toJSON heliumPrefs)} '. * $s' "$prefs" > "$tmp"
        run mv "$tmp" "$prefs"
      fi
    fi
  '';

  home.file = {
    ".pi/agent/settings.json".source = link "pi/settings.json";
    ".pi/agent/APPEND_SYSTEM.md".source = link "pi/APPEND_SYSTEM.md";
    ".pi/agent/skills".source = link "pi/skills";
    ".pi/agent/extensions".source = link "pi/extensions";
  }
  // lib.mapAttrs' (_: id:
    lib.nameValuePair "Library/Application Support/net.imput.helium/External Extensions/${id}.json" {
      # Helium drops prodversion from update checks, and without it the Web Store answers "noupdate"
      text = builtins.toJSON { external_update_url = "https://clients2.google.com/service/update2/crx?prodversion=156.0"; };
    }
  ) heliumExtensions;
}
