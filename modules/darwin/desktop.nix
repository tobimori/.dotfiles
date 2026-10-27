{ asUser, pkgs, ... }:
let
  wallpaper = "/System/Library/Desktop Pictures/Solid Colors/Black.png";
  # NSWorkspace needs no Automation permission, unlike System Events
  setWallpaper = pkgs.writeText "set-wallpaper.js" ''
    ObjC.import("AppKit");
    function run(argv) {
      const url = $.NSURL.fileURLWithPath(argv[0]);
      const ws = $.NSWorkspace.sharedWorkspace;
      const screens = $.NSScreen.screens;
      for (let i = 0; i < screens.count; i++) {
        const screen = screens.objectAtIndex(i);
        if (ws.desktopImageURLForScreen(screen).path.js !== argv[0]) {
          ws.setDesktopImageURLForScreenOptionsError(url, screen, $({}), null);
        }
      }
    }
  '';
in
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
      persistent-others = [ ];
    };
    WindowManager = {
      HideDesktop = true;
      StandardHideWidgets = true;
      StageManagerHideWidgets = true;
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

    ${asUser} /usr/bin/osascript -l JavaScript ${setWallpaper} "${wallpaper}" || true
  '';
}
