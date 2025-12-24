# Automates port forwarding for WireGuard VPN clients using **NAT-PMP**
# to dynamically reserve ports on the router.
# It handles TCP and UDP traffic for WireGuard peers and manages iptables rules to redirect traffic.
# Notes
# - Some servers, even under the same provider, may not support NAT-PMP even if they claim to do so.
# - Proton VPN: PT didn't work, but NL did work.
# Original: https://github.com/ImUrX/nixfiles/blob/b94ed89a7025b68b60ed7cb4254b5512d1ec0f25/modules/wg-pnp.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  basedOn = lib.types.submodule {
    options = with lib; {
      # VPN Namespace: Used to isolate WireGuard's network namespace.
      vpnNamespace = mkOption {
        type = types.str;
        description = ''
          Name of the WireGuard VPN's network namespace.
          Must match the namespace created by your WireGuard setup.
          Used for confinement and rule binding.'';
      };
      # Script code to run after port refresh.
      runScript = mkOption {
        type = types.str;
        description = ''
          Script to run after there is a port refresh.
          Useful for additional post-renewal logic like logging or notifications.
        '';
      };
    };
  };
  # Reference to the actual configuration in NixOS's `uri` options.
  cfg = config.uri.wg-pnp;
in
with lib;
{
  # Define the top-level configuration options for `uri.wg-pnp`.
  # Users can override these per-peer settings.
  options.uri.wg-pnp = mkOption {
    type = types.attrsOf basedOn;
    default = { };
  };

  config = mkIf (cfg != { }) {

    # 1. Systemd Timers:
    # Define timers to refresh ports periodically (to account for NAT-PMP lease expiration).
    # Runs every 45 seconds after boot and whenever the WireGuard service activates.
    systemd.timers = mapAttrs' (
      n: v: # `n` = peer name, `v` = peer config.
      nameValuePair "${n}-port-forwarding" {
        wantedBy = [ "timers.target" ];
        after = [ "${n}.service" ]; # Waits for WireGuard service to be active.
        timerConfig = {
          OnBootSec = "45s"; # Refresh on boot.
          OnUnitActiveSec = "45s"; # Refresh whenever WireGuard updates.
          Unit = "${n}-port-forwarding.service"; # Reference the service below.
        };
      }
    ) cfg;

    # 2. Systemd Services:
    # Handles the actual port refresh logic using NAT-PMP and iptables.
    systemd.services = mapAttrs' (
      n: v:
      nameValuePair "${n}-port-forwarding" {
        serviceConfig = {
          Type = "oneshot"; # Runs once and exits.
          User = "root"; # Requires root privileges for iptables.
        };

        # Dependencies: Must run after WireGuard's namespace is active
        bindsTo = [ "${v.vpnNamespace}.service" ];
        after = [ "${v.vpnNamespace}.service" ];

        # Confinement: Ensure service runs in the WireGuard namespace.
        vpnConfinement = {
          enable = true;
          vpnNamespace = v.vpnNamespace;
        };

        # Core logic for refreshing ports.
        script = ''
          set -u

          # --- Helper Function ---
          # `renew_port`: Attempts to map a port (TCP/UDP) via NAT-PMP.
          # Updates iptables rules and triggers any post-renewal script.
          renew_port() {
            # tcp or udp
            protocol="$1"
            # Stores mapped port for this peer/protocol.
            port_file="/tmp/${n}-$protocol-port"
            # Interface for WireGuard's namespace.
            GATEWAY="${v.vpnNamespace}0"
            # Static internal port (always redirected to this).
            FIXED_INTERNAL_PORT=51413

            # VPN DNS Server, usually in wg.conf
            VPN_DNS_SERVER="10.2.0.1"

            touch $port_file

            # --- NAT-PMP: Get a Public Port ---
            # Request a port from the router (timeout: 60s, lease to VPN_DNS_SERVER).
            result="$(${pkgs.libnatpmp}/bin/natpmpc -a 1 $FIXED_INTERNAL_PORT "$protocol" 60 -g "$VPN_DNS_SERVER")"
            echo "$result"

            # Extract the mapped public port from the output.
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
            # Redirect traffic on 51413 to the public port
            if ! ${pkgs.iptables}/bin/iptables -t nat -C PREROUTING -p "$protocol" --dport "$FIXED_INTERNAL_PORT" -j REDIRECT --to-port "$public_port" 2>/dev/null; then
                echo "Adding Redirect: $FIXED_INTERNAL_PORT -> $public_port"
                ${pkgs.iptables}/bin/iptables -t nat -I PREROUTING -p "$protocol" --dport "$FIXED_INTERNAL_PORT" -j REDIRECT --to-port "$public_port"
            fi

            # --- Run Custom Post-Renew Script ---
            ${v.runScript}

            # --- Cleanup ---
            # Close the old port if it changed.
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

          # --- MAIN ENTRYPOINT ---
          renew_port udp
          renew_port tcp
        '';

      }
    ) cfg;
  };
}
