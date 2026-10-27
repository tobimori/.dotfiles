{
  asUser,
  config,
  ...
}:
{
  imports = [
    ../modules/darwin/base.nix
    ../modules/darwin/remote-access.nix
    ../modules/darwin/desktop.nix
    ../modules/darwin/keyboard.nix
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

  system.defaults.dock.persistent-apps = [ ];

  power.restartAfterFreeze = true;

  # Agents run as this user and can already reach everything of value on this machine
  security.sudo.extraConfig = ''
    ${config.system.primaryUser} ALL=(ALL) NOPASSWD: ALL
  '';

  # The lock screen ignores displaysleep 0, and the JetKVM loses its signal when the display sleeps
  launchd.daemons.keepawake.serviceConfig = {
    ProgramArguments = [
      "/usr/bin/caffeinate"
      "-dims"
    ];
    RunAtLoad = true;
    KeepAlive = true;
  };

  # Homebrew refuses to run until the Xcode license is accepted
  system.activationScripts.preActivation.text = ''
    if [ -d /Applications/Xcode.app ]; then
      xcode-select -s /Applications/Xcode.app
      xcodebuild -license accept
      xcodebuild -runFirstLaunch
      xcrun simctl list runtimes | grep -q '^iOS' || xcodebuild -downloadPlatform iOS
    fi
  '';

  system.activationScripts.postActivation.text = ''
    pmset -a sleep 0 displaysleep 0 disksleep 0 disablesleep 1 standby 0 powernap 0
    ${asUser} defaults -currentHost write com.apple.screensaver idleTime -int 0

    # With the lid open, the lock screen shows only on the built-in display, so mirror it to the JetKVM.
    # A mirrored or closed built-in display is not listed
    dp=/opt/homebrew/bin/displayplacer
    if ${asUser} "$dp" list 2>/dev/null | grep -q 37D8832A-2D66-02CA-B9F7-8F30A301B230; then
      ${asUser} "$dp" \
        "id:82625F97-55BD-4893-9806-00C28FD06F06+37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1920x1080 hz:60 color_depth:8 scaling:off origin:(0,0) degree:0" || true
    fi
  '';

  # T3 Code installs its own launchd agent and updates itself
  home-manager.users.${config.system.primaryUser} =
    { lib, ... }:
    {
      home.activation.devTools = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        export PNPM_HOME="$HOME/.local/share/pnpm"
        export PATH="$PNPM_HOME/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
        # Otherwise mise exec installs every tool in the config, and PHP needs a compiler toolchain
        export MISE_EXEC_AUTO_INSTALL=false
        mise which pnpm >/dev/null 2>&1 || run mise install node pnpm
        [ -x "$PNPM_HOME/bin/pi" ] || run mise exec -- pnpm add -g @earendil-works/pi-coding-agent
        [ -d "$HOME/.t3/runtime" ] || run mise exec -- pnpm dlx t3@nightly service install
      '';
    };

  system.stateVersion = 6;
}
