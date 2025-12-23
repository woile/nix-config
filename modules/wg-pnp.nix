{
  config,
  lib,
  pkgs,
  ...
}:
let
  basedOn = lib.types.submodule {
    options = with lib; {
      vpnNamespace = mkOption {
        type = types.str;
        description = "Name of the VPN namespace";
      };
      runScript = mkOption {
        type = types.str;
        description = "Script to run when there is a port refresh";
      };
    };
  };
  cfg = config.uri.wg-pnp;
in
with lib;
{
  options.uri.wg-pnp = mkOption {
    type = types.attrsOf basedOn;
    default = { };
  };

  config = mkIf (cfg != { }) {

    systemd.timers = mapAttrs' (
      n: v:
      nameValuePair ("${n}-port-forwarding") ({
        wantedBy = [ "timers.target" ];
        after = [ "${n}.service" ];
        timerConfig = {
          OnBootSec = "45s";
          OnUnitActiveSec = "45s";
          Unit = "${n}-port-forwarding.service";
        };
      })
    ) cfg;

    systemd.services = mapAttrs' (
      n: v:
      nameValuePair "${n}-port-forwarding" {
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        bindsTo = [ "${v.vpnNamespace}.service" ];
        after = [ "${v.vpnNamespace}.service" ];

        vpnConfinement = {
          enable = true;
          vpnNamespace = v.vpnNamespace;
        };

        script = ''
          set -u

          renew_port() {
            protocol="$1"
            port_file="/tmp/${n}-$protocol-port"
            touch $port_file

            # Open port 5351 for NAT-PMP
            ${pkgs.iptables}/bin/iptables -I INPUT -p udp --sport 5351 -j ACCEPT -i ${v.vpnNamespace}0

            result="$(${pkgs.libnatpmp}/bin/natpmpc -a 1 0 "$protocol" 60 -g 10.2.0.1)"
            echo "$result"

            new_port="$(echo "$result" | ${pkgs.ripgrep}/bin/rg --only-matching --replace '$1' 'Mapped public port (\d+) protocol ... to local port 0 lifetime 60')"
            old_port="$(cat "$port_file")"
            echo "Mapped new $protocol port $new_port, old one was $old_port."
            echo "$new_port" >"$port_file"

            if ${pkgs.iptables}/bin/iptables -C INPUT -p "$protocol" --dport "$new_port" -j ACCEPT -i ${v.vpnNamespace}0
            then
              echo "New $protocol port $new_port already open, not opening again."
            else
              echo "Opening new $protocol port $new_port."
              ${pkgs.iptables}/bin/iptables -I INPUT -p "$protocol" --dport "$new_port" -j ACCEPT -i ${v.vpnNamespace}0
            fi

            ${v.runScript}

            if [ "$new_port" -eq "$old_port" ]
            then
              echo "New $protocol port $new_port is the same as old port $old_port, not closing old port."
            else
              if ${pkgs.iptables}/bin/iptables -C INPUT -p "$protocol" --dport "$old_port" -j ACCEPT -i ${v.vpnNamespace}0
              then
                echo "Closing old $protocol port $old_port."
                ${pkgs.iptables}/bin/iptables -D INPUT -p "$protocol" --dport "$old_port" -j ACCEPT -i ${v.vpnNamespace}0
              else
                echo "Old $protocol port $old_port not open, not attempting to close."
              fi
            fi
          }

          renew_port udp
          renew_port tcp
        '';
      }
    ) cfg;
  };
}
