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

  system.activationScripts.postActivation.text = ''
    ${asUser} /opt/homebrew/bin/displayplacer \
      "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1637x1024 scaling:on" || true
  '';

  system.stateVersion = 6;
}
