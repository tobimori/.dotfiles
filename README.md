# dotfiles

nix-darwin, nix-homebrew and home-manager for `tiny` (MacBook Neo) and `hole` (MacBook Pro, CI and agents).

## New Mac

1. Finish Setup Assistant with the user `tm`.
2. Install the Command Line Tools (`xcode-select --install`) and [Determinate Nix](https://install.determinate.systems/determinate-pkg/stable/Universal).
3. `git clone https://github.com/tobimori/.dotfiles ~/dotfiles`
4. `sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles#<host>`
5. Log in the SSH node: `sudo tailscale-ssh up --ssh --hostname <host>-ssh`.
6. In System Settings, give `/usr/local/libexec/tailscaled-ssh` Full Disk Access.

Later: `update` updates the flake inputs, rebuilds and upgrades Homebrew.

## Manual steps on `hole`

macOS allows these only in System Settings, or only with the password:

- Privacy & Security > Allow accessories to connect: **Always**, so the JetKVM keyboard works at the lock screen
- General > Sharing > Screen Sharing: on
- FileVault off, then automatic login: `sysadminctl -autologin set` fails for accounts linked to an Apple Account, so write `/etc/kcpassword` and `autoLoginUser` directly
- Screen lock off: `sysadminctl -screenLock off -password -`
