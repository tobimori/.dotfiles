{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "tailscale-ssh" ''
      exec ${pkgs.tailscale}/bin/tailscale --socket=/var/run/tailscale-ssh.sock "$@"
    '')
  ];

  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = true;
    allowSigned = true;
    allowSignedApp = true;
  };

  services.openssh.enable = false;

  # Second, userspace-only tailscaled next to the Tailscale app, because only the
  # open source variant can be a Tailscale SSH server on macOS
  # https://tailscale.com/docs/concepts/macos-variants
  # Full Disk Access follows the code signature, and Nix binaries are only ad-hoc
  # signed. A copy signed with a local self-signed certificate keeps the grant
  # across Tailscale updates. bin/tailscaled is a wrapper that only adds lsof to PATH
  system.activationScripts.preActivation.text = ''
    ident="tailscaled-ssh signing"
    kc=/Library/Keychains/System.keychain
    if ! security find-certificate -c "$ident" "$kc" >/dev/null 2>&1; then
      t=$(mktemp -d)
      /usr/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 36500 -subj "/CN=$ident" \
        -addext "extendedKeyUsage=critical,codeSigning" -addext "keyUsage=critical,digitalSignature" \
        -keyout "$t/key.pem" -out "$t/cert.pem" 2>/dev/null
      /usr/bin/openssl pkcs12 -export -inkey "$t/key.pem" -in "$t/cert.pem" -out "$t/id.p12" -passout pass:import
      security import "$t/id.p12" -k "$kc" -P import -T /usr/bin/codesign
      rm -rf "$t"
    fi

    src=${pkgs.tailscale}/bin/.tailscaled-wrapped
    dst=/usr/local/libexec/tailscaled-ssh
    if [ "$(cat "$dst.source" 2>/dev/null)" != "$src" ]; then
      install -d /usr/local/libexec
      install -m 755 "$src" "$dst"
      codesign -f -i tailscaled-ssh \
        -s "$(security find-certificate -c "$ident" -Z "$kc" | awk '/SHA-1/ { print $3 }')" "$dst"
      echo "$src" > "$dst.source"
      touch /var/run/tailscaled-ssh.updated
    fi
  '';

  system.activationScripts.postActivation.text = ''
    if [ -e /var/run/tailscaled-ssh.updated ]; then
      rm /var/run/tailscaled-ssh.updated
      launchctl kickstart -k system/org.nixos.tailscaled-ssh || true
    fi
  '';

  launchd.daemons.tailscaled-ssh.serviceConfig = {
    ProgramArguments = [
      "/usr/local/libexec/tailscaled-ssh"
      "--tun=userspace-networking"
      "--statedir=/var/lib/tailscale-ssh"
      "--socket=/var/run/tailscale-ssh.sock"
      "--port=0"
    ];
    EnvironmentVariables.PATH = "${pkgs.lsof}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
    RunAtLoad = true;
    KeepAlive = true;
    StandardErrorPath = "/var/log/tailscaled-ssh.log";
  };

  # SSH and Screen Sharing only from the tailnet. A sub-anchor of com.apple is
  # evaluated by the stock /etc/pf.conf, which macOS updates overwrite
  launchd.daemons.pf-tailscale-only.serviceConfig = {
    ProgramArguments = [
      "/bin/sh"
      "-c"
      "/sbin/pfctl -E; /sbin/pfctl -f /etc/pf.conf; /sbin/pfctl -a com.apple/tailscale-only -f ${pkgs.writeText "tailscale-only.pf" ''
        ports = "{ 22, 3283, 5900, 5901, 5902 }"
        pass in quick on lo0 all
        pass in quick inet proto { tcp, udp } from 100.64.0.0/10 to any port $ports
        pass in quick inet6 proto { tcp, udp } from fd7a:115c:a1e0::/48 to any port $ports
        block in quick proto { tcp, udp } from any to any port $ports
      ''}"
    ];
    RunAtLoad = true;
  };
}
