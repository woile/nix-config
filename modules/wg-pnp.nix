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
            GATEWAY="${v.vpnNamespace}0"
            FIXED_INTERNAL_PORT=0

            touch $port_file

            # 1. Allow NAT-PMP responses (The fix we found earlier)
            # This opens the door for the "Resource temporarily unavailable" fix
            # ${pkgs.iptables}/bin/iptables -C INPUT -p udp --sport 5351 -j ACCEPT -i $GATEWAY 2>/dev/null || ${pkgs.iptables}/bin/iptables -I INPUT -p udp --sport 5351 -j ACCEPT -i $GATEWAY

            result="$(${pkgs.libnatpmp}/bin/natpmpc -a 1 $FIXED_INTERNAL_PORT "$protocol" 60 -g 10.2.0.1)"
            echo "$result"

            public_port="$(echo "$result" | ${pkgs.ripgrep}/bin/rg --only-matching --replace '$1' "Mapped public port (\d+) protocol ... to local port $FIXED_INTERNAL_PORT lifetime 60")"

            if [ -z "$public_port" ]; then
              echo "FAILED. Output: $result"
              return
            fi

            old_port="$(cat "$port_file")"
            echo "Mapped new $protocol port $public_port, old one was $old_port."
            echo "$public_port" >"$port_file"

            # --- INPUT Rule (Open the Public Port) ---
            if ${pkgs.iptables}/bin/iptables -C INPUT -p "$protocol" --dport "$public_port" -j ACCEPT -i $GATEWAY
            then
              echo "New $protocol port $public_port already open, not opening again."
            else
              echo "Opening new $protocol port $public_port."
              ${pkgs.iptables}/bin/iptables -I INPUT -p "$protocol" --dport "$public_port" -j ACCEPT -i $GATEWAY
            fi

            # --- REDIRECT Rule (Internal Fixed -> Public) ---
            # This ensures traffic arriving at 51413 gets forwarded to the random Public Port
            if ! ${pkgs.iptables}/bin/iptables -t nat -C PREROUTING -p "$protocol" --dport "$FIXED_INTERNAL_PORT" -j REDIRECT --to-port "$public_port" 2>/dev/null; then
                echo "Adding Redirect: $FIXED_INTERNAL_PORT -> $public_port"
                ${pkgs.iptables}/bin/iptables -t nat -I PREROUTING -p "$protocol" --dport "$FIXED_INTERNAL_PORT" -j REDIRECT --to-port "$public_port"
            fi

            ${v.runScript}

            # --- Cleanup ---
            if [ "$public_port" -eq "$old_port" ]
            then
              echo "New $protocol port $public_port is the same as old port $old_port, not closing old port."
            else
              if ${pkgs.iptables}/bin/iptables -C INPUT -p "$protocol" --dport "$old_port" -j ACCEPT -i $GATEWAY
              then
                echo "Closing old $protocol port $old_port."
                ${pkgs.iptables}/bin/iptables -D INPUT -p "$protocol" --dport "$old_port" -j ACCEPT -i $GATEWAY
              else
                echo "Old $protocol port $old_port not open, not attempting to close."
              fi

              # Remove old REDIRECT rule (Clean up the nat table)
              # Note: We blindly try to delete the rule redirecting to the OLD port
              if ${pkgs.iptables}/bin/iptables -t nat -C PREROUTING -p "$protocol" --dport "$FIXED_INTERNAL_PORT" -j REDIRECT --to-port "$old_port" 2>/dev/null; then
                echo "Removing old Redirect: $FIXED_INTERNAL_PORT -> $old_port"
                ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -p "$protocol" --dport "$FIXED_INTERNAL_PORT" -j REDIRECT --to-port "$old_port"
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
