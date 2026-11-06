{ config, ... }:
{
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
      '';
    };
}
