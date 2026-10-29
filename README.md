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

`hole` deploys itself with [comin](https://github.com/nlewo/comin): it builds `main` when the last commit is signed with the 1Password key "GitHub signing". Check it with `comin status` or `/var/log/comin.log`.

## Simlock on `hole`

`hole` leases iOS simulators to agents on the tailnet with [Simlock](https://github.com/callstackincubator/simlock), at `https://hole-ssh.tail62331.ts.net` (`modules/darwin/simlock.nix`). To connect another machine:

1. On `hole`: `simlock token create --role agent --label <machine>`. The secret shows only once.
2. On the machine, install `agent-device` 0.21.28 or later and write `~/.config/simlock/hole.json` with mode 0600:
   ```json
   {
     "daemonBaseUrl": "https://hole-ssh.tail62331.ts.net/v1/agent-device",
     "daemonAuthToken": "<secret>",
     "daemonTransport": "http",
     "leaseProvider": "proxy",
     "sessionIsolation": "tenant",
     "tenant": "<machine>",
     "runId": "<machine>",
     "clientId": "<openssl rand -hex 8>"
   }
   ```
3. Each agent session uses its own session name:
   ```sh
   agent-device connect --remote-config ~/.config/simlock/hole.json --session <name>
   agent-device open --platform ios --session <name>
   agent-device close --session <name>
   ```

## Manual steps on `hole`

macOS allows these only in System Settings, or only with the password:

- Privacy & Security > Allow accessories to connect: **Always**, so the JetKVM keyboard works at the lock screen
- JetKVM keyboard layout: English (US), to match EurKEY
- General > Sharing > Screen Sharing: on
- Bluetooth: off. `blueutil` would need Bluetooth access for `tailscaled-ssh`
- Battery > Charging (i) > Charge Limit: **80 %**, because the battery stays on the charger all the time. Check with `pmset -g battlimit`
- FileVault off, then automatic login: `sysadminctl -autologin set` fails for accounts linked to an Apple Account, so write `/etc/kcpassword` and `autoLoginUser` directly
- Screen lock off: `sysadminctl -screenLock off -password -`
- Xcode: install it once in the App Store app. `mas` fails as root on macOS 27. The next rebuild accepts the license and installs the iOS simulator
