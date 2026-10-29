{ config, pkgs, ... }:
let
  user = config.system.primaryUser;
  # Built from main: the npm release is from before the HTTP API and agent-device support
  rev = "7ac7f18f58beaf7f69be80cc9977f0a10b633383";
  src = "/Users/${user}/.local/share/simlock";
  agentDevice = "0.21.33";
  # pnpm 11 keeps global packages under hashed directories, so install it into a fixed one
  agentDeviceDir = "/Users/${user}/.local/share/agent-device";
  androidCmdlineTools = pkgs.fetchzip {
    url = "https://dl.google.com/android/repository/commandlinetools-mac_arm64-16111833_latest.zip";
    hash = "sha256-+JN101vIjhAsrPKasK8xe29aBOA7hUL/QDSKe9TJnNg=";
  };
in
{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "simlock" ''
      exec "$(mise which node)" ${src}/dist/cli/main.js "$@"
    '')
  ];

  # The userspace tailscaled forwards tailnet connections to 127.0.0.1:4701 as plain HTTP,
  # and Serve adds HTTPS on https://<host>-ssh.<tailnet>.ts.net
  system.activationScripts.postActivation.text = ''
    ${pkgs.tailscale}/bin/tailscale --socket=/var/run/tailscale-ssh.sock serve --bg --https=443 http://127.0.0.1:4701 >/dev/null \
      || echo "warning: could not serve simlock over HTTPS, log in tailscale-ssh first"
  '';

  home-manager.users.${user} =
    { lib, ... }:
    {
      # Simlock finds the package two levels above the command, so it must name the real bin file
      home.file.".simlock/config.json" = {
        text = builtins.toJSON {
          capabilities = {
            agent-device.command = "${agentDeviceDir}/node_modules/agent-device/bin/agent-device.mjs";
            stream.enabled = true;
          };
          downloads.acceptAndroidLicenses = true;
          android.emulator.headless = true;
          warmPool.targets = [
            {
              platform = "ios";
              model = "iPhone Duo";
              count = 1;
            }
            {
              platform = "ios";
              model = "iPad Pro 11-inch (M5)";
              count = 1;
            }
          ];
        };
        onChange = "/bin/launchctl kickstart -k gui/$(id -u)/com.callstack.simlock.worker || true";
      };

      home.activation.simlock = lib.hm.dag.entryAfter [ "devTools" "onFilesChange" ] ''
        export PNPM_HOME="$HOME/.local/share/pnpm"
        export PATH="$PNPM_HOME/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
        export MISE_EXEC_AUTO_INSTALL=false
        fresh=
        ad=${agentDeviceDir}
        if [ "$(jq -r .version "$ad/node_modules/agent-device/package.json" 2>/dev/null)" != ${agentDevice} ]; then
          run mkdir -p "$ad"
          run mise exec node pnpm -- pnpm add --dir "$ad" agent-device@${agentDevice}
          fresh=1
        fi

        # Simlock installs system images itself, so the SDK lives outside the store where Simlock looks by default
        sdk="$HOME/Library/Android/sdk"
        export JAVA_HOME=${pkgs.jdk21.home}
        if [ "$(cat "$sdk/cmdline-tools/latest/.source" 2>/dev/null)" != ${androidCmdlineTools} ]; then
          run rm -rf "$sdk/cmdline-tools/latest"
          run mkdir -p "$sdk/cmdline-tools"
          run cp -R ${androidCmdlineTools} "$sdk/cmdline-tools/latest"
          run chmod -R u+w "$sdk/cmdline-tools/latest"
          run sh -c 'echo "$1" > "$2"' _ ${androidCmdlineTools} "$sdk/cmdline-tools/latest/.source"
        fi
        if [ ! -x "$sdk/emulator/emulator" ] || [ ! -x "$sdk/platform-tools/adb" ]; then
          run sh -c 'yes | "$1/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null; "$1/cmdline-tools/latest/bin/sdkmanager" --install emulator platform-tools' _ "$sdk"
          fresh=1
        fi

        src=${src}
        if [ "$(cat "$src/.built" 2>/dev/null)" != ${rev} ]; then
          run rm -rf "$src"
          run git init -q "$src"
          run git -C "$src" fetch -q --depth 1 https://github.com/callstackincubator/simlock ${rev}
          run git -C "$src" checkout -q FETCH_HEAD
          run sh -c 'cd "$1" && mise exec node pnpm -- pnpm install --frozen-lockfile && mise exec node pnpm -- pnpm build && echo "$2" > .built' _ "$src" ${rev}
          fresh=1
        fi

        # The service stores the paths of node and simlock and the environment, and the worker looks for
        # agent-device and the Android SDK only when it starts, so any of these changing needs a new install
        node=$(mise which node)
        service="$node $JAVA_HOME"
        if [ -n "$fresh" ] || [ "$(cat "$src/.service" 2>/dev/null)" != "$service" ] \
          || ! "$node" "$src/dist/cli/main.js" daemon status 2>/dev/null | grep -q '^Service: installed'; then
          run "$node" "$src/dist/cli/main.js" daemon install && run sh -c 'echo "$1" > "$2"' _ "$service" "$src/.service" \
            || echo "warning: could not install the simlock service"
        fi
      '';
    };
}
