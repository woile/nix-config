{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe'
    types
    ;
  cfg = config.services.netbird.proxy;
  cmd = getExe' cfg.package "netbird-proxy";
  args = lib.cli.toCommandLineShellGNU { } (cfg.settings);
in
{
  options.services.netbird.proxy = {
    enable = lib.mkEnableOption "Netbird's Proxy Service";
    package = lib.mkPackageOption pkgs "netbird-proxy" { };

    settings = lib.mkOption {
      type = types.submodule {
        freeformType =
          with lib.types;
          attrsOf (
            nullOr (oneOf [
              bool
              str
              (listOf (oneOf [ str ]))
            ])
          );

        options.domain = lib.mkOption {
          type = types.str;
          description = "The Domain at which this proxy will be reached.";
          example = "proxy.example.com";
        };
        options.mgmt = lib.mkOption {
          type = types.str;
          description = "Management address to connect to";
          example = "https://api.netbird.io:443";
        };

        options.addr = lib.mkOption {
          type = types.str;
          description = "Reverse proxy address to listen on";
          default = ":8447";
        };

        # TODO: Find out what should I use here for this value
        options.trusted-proxies = lib.mkOption {
          type = types.str;
          description = "Comma-separated list of trusted upstream proxy CIDR ranges (e.g. '10.0.0.0/8,192.168.1.1')";
          default = "127.0.0.1/32";
        };

        options.proxy-protocol = lib.mkOption {
          type = types.bool;
          description = "Enable PROXY protocol on TCP listeners to preserve client IPs behind L4 proxies";
          default = true;
        };

        options.cert-dir = lib.mkOption {
          type = types.externalPath;
          description = "Directory containing the TLS certificate pair.";
          example = "/var/lib/acme/proxy.example.com";
        };

        options.cert-file = lib.mkOption {
          type = types.str;
          description = "Certificate file name inside `cert-dir`.";
          default = "fullchain.pem"; # security.acme layout
        };

        options.cert-key-file = lib.mkOption {
          type = types.str;
          description = "Key file name inside `cert-dir`.";
          default = "key.pem"; # security.acme layout
        };
      };

    };
    environment = lib.mkOption {
      type = types.submodule {
        freeformType =
          with lib.types;
          attrsOf (oneOf [
            str
            bool
            int
          ]);
      };
      example = {
        NB_PROXY_PRIVATE = true;
        NB_PROXY_LOG_LEVEL = "info";
      };
      default = { };
      description = ''
        Feed environment variables to the proxy. Some parameters can only be provided via environments.

        Warning: Do not put secrets here.
      '';
    };
    proxyTokenFile = lib.mkOption {
      type = types.externalPath;
      description = ''
        Path (as string) to a file containing the netbird proxy token.
        It will populate `NB_PROXY_TOKEN`.

        Obtain with netbird-mgmt admin --config /var/lib/netbird-mgmt/management.json token create --name "<name>"
      '';
      example = "/run/proxy_token_secret";
    };

  };

  config = lib.mkIf cfg.enable {
    systemd.services.netbird-proxy = {
      description = "Proxy for Netbird, a wireguard VPN";
      documentation = [
        "https://netbird.io/docs/"
        "https://docs.netbird.io/selfhosted/migration/enable-reverse-proxy"
        "https://docs.netbird.io/manage/reverse-proxy"
      ];

      after = [
        "network.target"
      ];
      wantedBy = [ "multi-user.target" ];

      environment = lib.mapAttrs (_: lib.generators.mkValueStringDefault { }) cfg.environment;
      script = ''
        export NB_PROXY_TOKEN="$(< "$CREDENTIALS_DIRECTORY/proxy_token")"
        exec ${cmd} ${args}
      '';
      unitConfig = {
        # Spread the restart
        StartLimitIntervalSec = 60;
        StartLimitBurst = 10;
      };
      serviceConfig = {
        # Let systemd ingest the secret safely
        LoadCredential = "proxy_token:${cfg.proxyTokenFile}";
        Restart = "always";
        RestartSec = "5s";
        StateDirectory = "netbird";

        # Hardening::Start
        DynamicUser = true;
        LockPersonality = true;
        # Go runtime memory allocators frequently clash with MDWE
        MemoryDenyWriteExecute = false;

        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
        SystemCallErrorNumber = "EPERM"; # Returns an error rather than dumping core on unknown syscalls
        SupplementaryGroups = [ "acme" ];
        ReadOnlyPaths = [ cfg.settings.cert-dir ];

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];
        UMask = "0077";
        # Hardening::End
      };
    };
  };

  meta = {
    # doc = ./netbird-proxy.md;
    maintainers = [
      lib.maintainers.woile
    ];
  };

}
