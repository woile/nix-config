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
        extraDomainNames = [ vpnDomain ];
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
      # "${vpnDomain}" = {
      #   listenHTTP = "[::1]:3000";
      #   group = "acme";
      #   reloadServices = [ "traefik.service" ];
      # };
    };
  };

  # Open firewall
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [
    51821 # netbird client
    3478 # STUN port (UDP) for NetBird NAT discovery
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
    owner = "netbird-management";
    group = "netbird-management";
    mode = "0400";
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
      persons = {
        woile = {
          displayName = "Santi";
          mailAddresses = [ "santiwilly@gmail.com" ];
          groups = [
            "media"
            "vpn_users"
          ];
        };
      };

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
        enableLocalhostRedirects = true;
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
      turnDomain = vpnDomain;

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
          Secret = {
            _secret = config.age.secrets.netbird_turn_password.path;
          };
          Turns = [
            {
              Proto = "udp";
              URI = "turn:${vpnDomain}:3478";
            }
          ];
          CredentialsTTL = "12h";
        };
        Relay = {
          Addresses = [ "rels://${vpnDomain}:443/relay" ];
          CredentialsTTL = "24h0m0s";
          Secret = {
            _secret = config.age.secrets.netbird_turn_password.path;
          };
        };
        Stuns = [
          {
            URI = "stun:${vpnDomain}:3478";
            Proto = "udp";
          }
        ];
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
  };

  systemd.services.netbird-management = {
    serviceConfig = {
      User = "netbird-management";
      Group = "netbird-management";
    };
    after = [
      "traefik.service"
      "kanidm.service"
    ];
    wants = [
      "traefik.service"
      "kanidm.service"
    ];
  };

  age.secrets.netbird_amaru_setup_key = {
    file = ../../security/secrets/netbird_amaru_setup_key.age;
    owner = "netbird-wt0";
    group = "netbird-wt0";
    mode = "0440";
  };
  services.netbird.clients.wt0 = {
    environment = {
      # Forces the client to communicate with the self-hosted control plane
      NB_MANAGEMENT_URL = "https://${vpnDomain}";
    };
    # environment = {
    #   HOME = "/var/lib/netbird-wt0";
    # };

    # dir = {
    #   state = "/var/lib/netbird-wt0";
    # };

    # Automatically login to your Netbird network with a setup key
    # This is mostly useful for server computers.
    # For manual setup instructions, see the wiki page section below.
    login = {
      enable = true;

      # Path to a file containing the setup key for your peer
      # NOTE: if your setup key is reusable, make sure it is not copied to the Nix store.
      setupKeyFile = config.age.secrets.netbird_amaru_setup_key.path;
    };

    # Port used to listen to wireguard connections
    port = 51821;

    # Set this to true if you want the GUI client
    ui.enable = false;

    # This opens ports required for direct connection without a relay
    openFirewall = true;

    # This opens necessary firewall ports in the Netbird client's network interface
    openInternalFirewall = true;
  };
  services.resolved.enable = true;

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
          # http.tls.certResolver = "letsencrypt";
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
        # {
        #   certFile = "/var/lib/acme/${vpnDomain}/fullchain.pem";
        #   keyFile = "/var/lib/acme/${vpnDomain}/key.pem";
        # }
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

          # Netbird Relay
          vpn-relay = {
            rule = "Host(`${vpnDomain}`) && PathPrefix(`/relay`)";
            entryPoints = [ "websecure" ];
            service = "vpn-relay-svc";
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
            # 8012 is Netbird's default Signal port.
            loadBalancer.servers = [ { url = "h2c://[::1]:8012"; } ];
          };

          # Dashboard Nginx Static Server
          vpn-dashboard-svc = {
            loadBalancer.servers = [ { url = "http://[::1]:8080"; } ];
          };

          # Netbird Relay Service
          vpn-relay-svc = {
            loadBalancer.servers = [ { url = "http://127.0.0.1:33080"; } ];
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

  # Enable Podman virtualization for NetBird Relay
  virtualisation.oci-containers = {
    backend = "podman";
  };
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # NetBird Relay container
  virtualisation.oci-containers.containers.netbird-relay = {
    image = "netbirdio/relay:latest";
    ports = [
      "127.0.0.1:33080:33080" # Loopback for Traefik proxy
      "3478:3478/udp" # Public STUN port
    ];
    environment = {
      NB_LISTEN_ADDRESS = ":33080";
      NB_EXPOSED_ADDRESS = "rels://${vpnDomain}:443/relay";
      NB_LOG_LEVEL = "info";
      NB_ENABLE_STUN = "true";
      NB_STUN_PORTS = "3478";
    };
    environmentFiles = [
      "/run/netbird-relay.env"
    ];
  };

  # systemd service to generate the env file containing the decrypted secret
  systemd.services.podman-netbird-relay = {
    preStart = ''
      password=$(cat ${config.age.secrets.netbird_turn_password.path})
      echo "NB_AUTH_SECRET=$password" > /run/netbird-relay.env
      chmod 600 /run/netbird-relay.env
    '';
    # Make sure the decrypted age secret is present
    wants = [ "netbird-management.service" ];
    after = [ "netbird-management.service" ];
  };
}
