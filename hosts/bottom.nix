{ asUser, ... }:
{
  imports = [
    ../modules/darwin/base.nix
    ../modules/darwin/remote-access.nix
    ../modules/darwin/apps.nix
    ../modules/darwin/desktop.nix
    ../modules/darwin/keyboard.nix
    ../modules/darwin/helium.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "tiny";
  networking.computerName = "tiny";
  system.primaryUser = "tm";

  homebrew.brews = [ "displayplacer" ];

  system.defaults.dock.persistent-apps = [
    "/Applications/Mimestream.app"
    "/Applications/Helium.app"
    "/Applications/Beeper Desktop.app"
    "/Applications/T3 Code (Nightly).app"
    "/Applications/Ghostty.app"
  ];

  system.activationScripts.postActivation.text = ''
    ${asUser} /opt/homebrew/bin/displayplacer \
      "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1637x1024 scaling:on" || true

    # macOS asks for the password in a dialog, so this fails over SSH
    ca=${../certs/portless-ca.pem}
    if ! security verify-cert -c "$ca" -p basic -L -q; then
      security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$ca" \
        || echo "warning: could not trust the portless CA, run the rebuild in a local terminal"
    fi
  '';

  system.stateVersion = 6;
}
