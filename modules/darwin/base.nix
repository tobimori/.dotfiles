{ config, pkgs, ... }:
let
  user = config.system.primaryUser;
  home = "/Users/${user}";
  flake = "${home}/dotfiles";
in
{
  # Determinate Nix manages the Nix daemon and /etc/nix
  nix.enable = false;

  users.users.${user}.home = home;

  _module.args.asUser = ''launchctl asuser "$(id -u ${user})" sudo -u ${user}'';

  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  environment.systemPackages = with pkgs; [
    btop
    fd
    gh
    git
    jq
    micro
    mise
    ripgrep
    starship
    (writeShellScriptBin "update" ''
      set -eu
      nix flake update --flake ${flake}
      sudo darwin-rebuild switch --flake ${flake}#${config.networking.hostName}
      brew update
      brew upgrade
      git -C ${flake} diff --quiet flake.lock || git -C ${flake} commit -m "flake: update inputs" flake.lock
    '')
  ];

  nix-homebrew = {
    enable = true;
    inherit user;
  };

  # Rebuilds only install what is missing, `update` upgrades. Pinned taps would not pin
  # anything, because Homebrew installs from its API instead of the local tap checkouts
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.${user} = ../../home/tm.nix;
    sharedModules = [
      (
        { config, ... }:
        {
          # Absolute string path, so links point into the checkout and stay writable
          # https://github.com/nix-community/home-manager/issues/2085
          _module.args.link = path: config.lib.file.mkOutOfStoreSymlink "${flake}/${path}";
        }
      )
    ];
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.activationScripts.postActivation.text = ''
    if [ "$(dscl . -read /Users/${user} UserShell | awk '{print $2}')" != /run/current-system/sw/bin/fish ]; then
      chsh -s /run/current-system/sw/bin/fish ${user}
    fi
  '';
}
