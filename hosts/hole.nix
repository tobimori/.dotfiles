{ asUser, ... }:
{
  imports = [
    ../modules/darwin/base.nix
    ../modules/darwin/remote-access.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "hole";
  networking.computerName = "hole";
  system.primaryUser = "tm";
  time.timeZone = "Europe/Berlin";

  homebrew.brews = [
    "displayplacer"
    "xcodes"
  ];

  power.restartAfterFreeze = true;

  # The lock screen ignores displaysleep 0, and the JetKVM loses its signal when the display sleeps
  launchd.daemons.keepawake.serviceConfig = {
    ProgramArguments = [
      "/usr/bin/caffeinate"
      "-dims"
    ];
    RunAtLoad = true;
    KeepAlive = true;
  };

  system.activationScripts.postActivation.text = ''
    pmset -a sleep 0 displaysleep 0 disksleep 0 disablesleep 1 standby 0 powernap 0
    ${asUser} defaults -currentHost write com.apple.screensaver idleTime -int 0

    # Mirror the built-in display to the JetKVM, so the lock screen shows up there
    ${asUser} /opt/homebrew/bin/displayplacer \
      "id:82625F97-55BD-4893-9806-00C28FD06F06+37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1920x1080 hz:60 color_depth:8 scaling:off origin:(0,0) degree:0" || true
  '';

  system.stateVersion = 6;
}
