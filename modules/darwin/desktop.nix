{
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.4;
      tilesize = 48;
      show-recents = false;
      minimize-to-application = true;
      mru-spaces = false;
      # 1 = no action. macOS puts Quick Note on the bottom-right corner by default
      wvous-br-corner = 1;
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
    NSGlobalDomain.AppleShowAllExtensions = true;
    screencapture.location = "~/Pictures/Screenshots";
    CustomUserPreferences = {
      "com.apple.assistant.support"."Assistant Enabled" = false;
      "com.apple.Siri".StatusMenuVisible = false;
    };
  };
}
