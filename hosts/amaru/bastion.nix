{
  pkgs,
  config,
  lib,
  ...
}:
let
  authDomain = "auth.woile.dev";
  vpnDomain = "vpn.woile.dev";
in
{
  # TLS configuration
  security.acme = {
    acceptTerms = true;
    defaults.email = "santiwilly@gmail.com";

    certs = {
      "${authDomain}" = {
        # Run the ACME challenge server on an internal port
        listenHTTP = "[::1]:3000";

        # Make the certs readable by the 'acme' group
        group = "acme";

        # Automatically restart Traefik and Kanidm when the certificate renews
        reloadServices = [
          "traefik.service"
          "kanidm.service"
        ];
      };
      "${vpnDomain}" = {
        listenHTTP = "[::1]:3000";
        group = "acme";
        reloadServices = [ "traefik.service" ];
      };
    };
  };

  # Open firewall
  networking.firewall.allowedTCPPorts = [
    80
    443
    3000
    3478 # netbird
  ];
  networking.firewall.allowedUDPPorts = [
    3478 # netbird
    51821 # netbird client
  ];

  # Register Secrets
  age.secrets.kanidm_admin_password = {
    file = ../../security/secrets/kanidm_admin_password.age;
    owner = "kanidm";
    group = "kanidm"; # Optional, but good practice
  };
  age.secrets.kanidm_idm_admin_password = {
    file = ../../security/secrets/kanidm_idm_admin_password.age;
    owner = "kanidm";
    group = "kanidm"; # Optional, but good practice
  };
  # Netbird Secrets
  age.secrets.netbird_mgmt_secret = {
    file = ../../security/secrets/netbird_mgmt_secret.age;
    owner = "netbird-management";
    group = "netbird-management";
  };
  age.secrets.netbird_turn_password = {
    file = ../../security/secrets/netbird_turn_password.age;
    owner = "turnserver";
    group = "turnserver";
  };

  # Authentication
  services.kanidm = {
    package = pkgs.kanidm_1_10.withSecretProvisioning;

    server = {
      enable = true;
      settings = {
        domain = authDomain;
        origin = "https://${authDomain}";
        bindaddress = "[::]:8443";

        # db_path = "/var/lib/kanidm/kanidm.db";
        # Point directly to the NixOS ACME certificates
        tls_chain = "/var/lib/acme/${authDomain}/fullchain.pem";
        tls_key = "/var/lib/acme/${authDomain}/key.pem";

        # Log level (optional)
        log_level = "info";
      };
    };
    # Commands:
    # kanidm login --name USERNAME
    client = {
      enable = true;
      settings.uri = "https://${authDomain}";
    };
    provision = {
      enable = true;
      # Files containing the plaintext initial passwords
      # Provisioned via agenix
      adminPasswordFile = config.age.secrets.kanidm_admin_password.path;
      # Identity Management Administrator: for regular use, bound to kanidm acl rules
      idmAdminPasswordFile = config.age.secrets.kanidm_idm_admin_password.path;
      groups = {
        media = {
          overwriteMembers = false;
        };
        vpn_users = {
          overwriteMembers = false;
        };
      };

      systems.oauth2.netbird = {
        displayName = "Netbird VPN";
        originLanding = "https://${vpnDomain}";
        originUrl = [
          "https://${vpnDomain}/auth"
          "https://${vpnDomain}/silent-renew"
        ];
        public = true; # Required for Netbird's Single Page App (Dashboard)
        scopeMaps = {
          vpn_users = [
            "openid"
            "profile"
            "email"
            "offline_access"
          ];
        };
      };
    };
  };

  # Override Nginx just to serve the Netbird Dashboard locally for Traefik
  services.nginx = {
    enable = true;
    virtualHosts."${vpnDomain}" = {
      enableACME = lib.mkForce false;
      forceSSL = lib.mkForce false;
      listen = lib.mkForce [
        {
          addr = "[::1]";
          port = 8080;
        }
      ];
    };
  };
  services.netbird.server = {
    enable = true;
    domain = vpnDomain;

    management = {
      enable = true;
      domain = vpnDomain;
      dnsDomain = vpnDomain;

      enableNginx = false; # Handled by Traefik

      oidcConfigEndpoint = "https://${authDomain}/oauth2/openid/netbird/.well-known/openid-configuration";

      settings = {
        HttpConfig = {
          AuthAudience = "netbird";
          AuthIssuer = "https://${authDomain}/oauth2/openid/netbird";
        };
        DataStoreEncryptionKey = {
          _secret = config.age.secrets.netbird_mgmt_secret.path;
        };
        TURNConfig = {
          Turns = [
            {
              Proto = "udp";
              URI = "turn:${vpnDomain}:3478";
            }
          ];
          CredentialsTTL = "12h";
          Secret = {
            _secret = config.age.secrets.netbird_turn_password.path;
          };
        };
      };
    };

    dashboard = {
      enable = true;
      domain = vpnDomain;
      enableNginx = true;
      settings = {
        AUTH_AUTHORITY = "https://${authDomain}/oauth2/openid/netbird";
        AUTH_CLIENT_ID = "netbird";
        AUTH_SUPPORTED_SCOPES = "openid profile email";
        AUTH_REDIRECT_URI = "/auth";
        AUTH_SILENT_REDIRECT_URI = "/silent-renew";
      };
    };

    coturn = {
      enable = true;
      domain = vpnDomain;
      passwordFile = config.age.secrets.netbird_turn_password.path;
    };
  };
  # Reverse proxy
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints = {
        web = {
          address = "[::]:80";
          asDefault = true;
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure = {
          address = "[::]:443";
          asDefault = true;
          http.tls.certResolver = "letsencrypt";
        };
      };

      log = {
        level = "INFO";
        format = "json";
      };

      # certificatesResolvers.letsencrypt.acme = {
      #   email = "santiwilly@gmail.com";
      #   storage = "${config.services.traefik.dataDir}/acme.json";
      #   httpChallenge.entryPoint = "web";
      # };

      ping = {
        manualRouting = true;
      };
      # Access the Traefik dashboard on <Traefik IP>:8080 of your server
      # api.dashboard = true;
      # api.insecure = true;
    };
    # Dynamic Configuration
    dynamicConfigOptions = {
      tls.certificates = [
        {
          certFile = "/var/lib/acme/${authDomain}/fullchain.pem";
          keyFile = "/var/lib/acme/${authDomain}/key.pem";
        }
        {
          certFile = "/var/lib/acme/${vpnDomain}/fullchain.pem";
          keyFile = "/var/lib/acme/${vpnDomain}/key.pem";
        }
      ];
      http = {
        serversTransports.kanidm-transport = {
          serverName = "auth.woile.dev";
        };
        routers = {
          # Intercept Let's Encrypt ACME challenges and route them internally
          acme-challenge = {
            rule = "PathPrefix(`/.well-known/acme-challenge/`)";
            entryPoints = [ "websecure" ];
            service = "acme-client";
            tls = { }; # Use the default TLS cert config above
          };

          auth-router = {
            rule = "Host(`${authDomain}`)";
            entryPoints = [ "websecure" ];
            # Route traffic directly to Traefik's internal ping service
            service = "kanidm-backend";
            tls = { };
          };

          # Netbird HTTP API
          vpn-api = {
            rule = "Host(`${vpnDomain}`) && PathPrefix(`/api`)";
            entryPoints = [ "websecure" ];
            service = "vpn-api-svc";
            tls = { };
          };
          # Netbird gRPC API (Management)
          vpn-grpc-mgmt = {
            rule = "Host(`${vpnDomain}`) && PathPrefix(`/management.ManagementService/`)";
            entryPoints = [ "websecure" ];
            service = "vpn-grpc-mgmt-svc";
            tls = { };
          };

          # Netbird Signal (gRPC) - Handles peer-to-peer connection brokering
          vpn-grpc-signal = {
            rule = "Host(`${vpnDomain}`) && PathPrefix(`/signalexchange.SignalExchange/`)";
            entryPoints = [ "websecure" ];
            service = "vpn-signal-svc";
            tls = { };
          };

          # Netbird Dashboard Web UI
          vpn-dashboard = {
            rule = "Host(`${vpnDomain}`)";
            entryPoints = [ "websecure" ];
            service = "vpn-dashboard-svc";
            tls = { };
          };
        };

        services = {
          # The NixOS internal ACME challenge server
          acme-client = {
            loadBalancer.servers = [ { url = "http://[::1]:3000"; } ];
          };

          # The Kanidm backend
          kanidm-backend = {
            loadBalancer = {
              servers = [ { url = "https://[::1]:8443"; } ];
              serversTransport = "kanidm-transport";
            };
          };

          # HTTP/1.1 API Service (Forces cmux to route to REST API)
          vpn-api-svc = {
            loadBalancer.servers = [ { url = "http://[::1]:8011"; } ];
          };
          # HTTP/2 gRPC Service (Forces cmux to route to gRPC handlers)
          vpn-grpc-mgmt-svc = {
            # Traefik uses h2c protocol to correctly proxy HTTP/2 and HTTP/1.1 traffic to the same port
            loadBalancer.servers = [ { url = "h2c://[::1]:8011"; } ];
          };

          # Signal Service (Peer brokering)
          vpn-signal-svc = {
            # 10000 is Netbird's default Signal port.
            loadBalancer.servers = [ { url = "h2c://[::1]:10000"; } ];
          };

          # Dashboard Nginx Static Server
          vpn-dashboard-svc = {
            loadBalancer.servers = [ { url = "http://[::1]:8080"; } ];
          };
        };
      };
    };
  };

  # User configuration
  #   - Ensure they have permission to read the certs
  users.users.kanidm.extraGroups = [ "acme" ];
  users.users.traefik.extraGroups = [ "acme" ];
  users.groups.netbird-management = { };
  users.users.netbird-management = {
    isSystemUser = true;
    group = "netbird-management";
  };

  users.groups.turnserver = { };
  users.users.turnserver = {
    isSystemUser = true;
    group = "turnserver";
  };
}
