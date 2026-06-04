{
  pkgs,
  config,
  ...
}:
let
  authDomain = "auth.woile.dev";
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
    };
  };

  # Open firewall
  networking.firewall.allowedTCPPorts = [
    80
    443
    3000
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

    provision = {
      enable = true;
      # Files containing the plaintext initial passwords
      # Provisioned via agenix
      adminPasswordFile = config.age.secrets.kanidm_admin_password.path;
      # Identity Management Administrator: for regular use, bound to kanidm acl rules
      idmAdminPasswordFile = config.age.secrets.kanidm_idm_admin_password.path;
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
        };
      };
    };
  };

  # User configuration
  #   - Ensure they have permission to read the certs
  users.users.kanidm.extraGroups = [ "acme" ];
  users.users.traefik.extraGroups = [ "acme" ];
}
