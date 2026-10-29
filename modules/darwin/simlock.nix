{ config, pkgs, ... }:
let
  user = config.system.primaryUser;
  # Built from main: the npm release is from before the HTTP API and agent-device support
  rev = "7ac7f18f58beaf7f69be80cc9977f0a10b633383";
  src = "/Users/${user}/.local/share/simlock";
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
      home.activation.simlock = lib.hm.dag.entryAfter [ "devTools" ] ''
        export PNPM_HOME="$HOME/.local/share/pnpm"
        export PATH="$PNPM_HOME/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
        export MISE_EXEC_AUTO_INSTALL=false
        # The worker serves agent-device only when it finds the command on its PATH
        [ -x "$PNPM_HOME/bin/agent-device" ] || run mise exec -- pnpm add -g agent-device

        src=${src}
        fresh=
        if [ "$(cat "$src/.built" 2>/dev/null)" != ${rev} ]; then
          run rm -rf "$src"
          run git init -q "$src"
          run git -C "$src" fetch -q --depth 1 https://github.com/callstackincubator/simlock ${rev}
          run git -C "$src" checkout -q FETCH_HEAD
          run sh -c 'cd "$1" && mise exec node pnpm -- pnpm install --frozen-lockfile && mise exec node pnpm -- pnpm build && echo "$2" > .built' _ "$src" ${rev}
          fresh=1
        fi

        # The service stores the paths of node and simlock, so a new build or node version needs a new install
        node=$(mise which node)
        if [ -n "$fresh" ] || ! "$node" "$src/dist/cli/main.js" daemon status 2>/dev/null | grep -q '^Service: installed'; then
          run "$node" "$src/dist/cli/main.js" daemon install || echo "warning: could not install the simlock service"
        fi
      '';
    };
}
