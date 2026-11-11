{ config, ... }:
{
  imports = [
    ../modules/darwin/base.nix
    ../modules/darwin/remote-access.nix
    ../modules/darwin/apps.nix
    ../modules/darwin/desktop.nix
    ../modules/darwin/desktop-video.nix
    ../modules/darwin/dev-tools.nix
    ../modules/darwin/keyboard.nix
    ../modules/darwin/helium.nix
    ../modules/darwin/xcode.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "bottom";
  networking.computerName = "bottom";
  system.primaryUser = "tm";

  homebrew.brews = [
    "displayplacer"
    # mise compiles PHP. The plugin's README lists fewer packages than it needs
    # https://github.com/jdx/vfox-php/blob/main/hooks/post_install.lua
    "autoconf"
    "bison"
    "bzip2"
    "curl"
    "freetype"
    "gmp"
    "icu4c"
    "jpeg"
    "krb5"
    "libedit"
    "libiconv"
    "libpng"
    "libsodium"
    "libxml2"
    "libzip"
    "oniguruma"
    "openssl@3"
    "pkgconf"
    "re2c"
    "readline"
    "sqlite"
    "webp"
    "zlib"
  ];

  homebrew.casks = [ "obs" ];

  home-manager.users.${config.system.primaryUser} =
    { lib, ... }:
    {
      home.activation.miseTools = lib.hm.dag.entryAfter [ "devTools" ] ''
        PATH="/opt/homebrew/bin:$PATH" run mise install || echo "warning: mise could not install every tool"
      '';
    };

  system.defaults.dock.persistent-apps = [
    "/Applications/Mimestream.app"
    "/Applications/Helium.app"
    "/Applications/Beeper Desktop.app"
    "/Applications/T3 Code (Nightly).app"
    "/Applications/Rex Beta.app"
    "/Applications/Slack.app"
    "/Applications/Discord.app"
  ];

  system.activationScripts.postActivation.text = ''
    # macOS asks for the password in a dialog, so this fails over SSH
    ca=${../certs/portless-ca.pem}
    if ! security verify-cert -c "$ca" -p basic -L -q; then
      security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$ca" \
        || echo "warning: could not trust the portless CA, run the rebuild in a local terminal"
    fi
  '';

  system.stateVersion = 6;
}
