{
  pkgs,
  modulesPath,
  config,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    ./disks.nix
    ../../users/woile/user.nix
  ];
  boot.kernelParams = [ "console=ttyS0" ]; # for scaleway serial connection
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "/dev/vda";
  };
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  system.stateVersion = "26.11";

  networking.hostName = "amaru";
  networking.enableIPv6 = true;
  networking.useDHCP = true;
  networking.useNetworkd = true;

  networking.interfaces.ens2.ipv6.addresses = [
    {
      # Block assigned by Scaleway when created a Flexible IPv6
      # We make NixOS listen to all of it
      address = "2001:bc8:1d90:1f4f::";
      prefixLength = 64;
    }
  ];

  systemd.network.enable = true;
  nix.settings = {
    trusted-users = [
      "root"
      "woile"
      "@wheel"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  environment.shellAliases = {
    neofetch = "macchina";
    tig = "gitui";
    cat = "bat -pp";
    du = "dust";
    htop = "btm";
  };
  environment.systemPackages = with pkgs; [
    macchina
    dust
    gitui
    bottom
    systemctl-tui
  ];

  programs.starship.enable = true;
  programs.bash.enable = true;
  programs.bat.enable = true;

  # Do not request a password for sudo wheel members
  # DO NOT CHANGE OTHERWISE WE LOSE ACCESS TO THE VM
  security.sudo.wheelNeedsPassword = false;

  # Essential swap for 2GB RAM instance
  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "prohibit-password";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
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

      certificatesResolvers.letsencrypt.acme = {
        email = "santiwilly@gmail.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        httpChallenge.entryPoint = "web";
      };

      ping = {
        manualRouting = true;
      };
      # Access the Traefik dashboard on <Traefik IP>:8080 of your server
      # api.dashboard = true;
      # api.insecure = true;
    };
    # Dynamic Configuration
    dynamicConfigOptions = {
      http = {
        routers = {
          auth-router = {
            rule = "Host(`auth.woile.dev`)";
            entryPoints = [ "websecure" ];
            # Route traffic directly to Traefik's internal ping service
            service = "ping@internal";
            tls = {
              certResolver = "letsencrypt";
            };
          };
        };

        # Notice we deleted the 'services' block entirely!
        # Because ping@internal is built-in, we don't need to define it.
      };
    };
  };
}
