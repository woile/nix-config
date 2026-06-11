{ pkgs, config, ... }:
{

  # mDNS for local services discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
    publish.enable = true;
    publish.addresses = true;
    publish.workstation = true;
  };

  # Torrenting client
  services.transmission = {
    enable = true;
    openRPCPort = true;
    group = "media";
    package = pkgs.transmission_4;
    settings = {
      download-dir = "/media/media-store/media-center/transmission/download";
      incomplete-dir = "/media/media-store/media-center/transmission/.incomplete";
      incomplete-dir-enabled = true;
      "rpc-bind-address" = "192.168.15.1"; # Bind RPC/WebUI to VPN network namespace address

      # RPC-whitelist examples
      "rpc-whitelist" = "127.0.0.1,192.168.100.*,192.168.15.*,localhost,::1,*.local"; # Access from other machines on specific subnet
      "port-forwarding-enabled" = false;
      "rpc-whitelist-enabled" = true;
      "rpc-host-whitelist" = "*";
      "utp-enabled" = false;
    };
    extraFlags = [
      "-M" # disable upnp
    ];
  };

  imports = [
    ../../modules/wg-pnp.nix
  ];
  uri.wg-pnp.transmission = {
    vpnNamespace = "proton";
    runScript = ''
      if [ "$protocol" = tcp ]
      then
        echo "Telling transmission to listen on peer port $new_port."
        ${pkgs.transmission_4}/bin/transmission-remote 192.168.15.1 --port "$new_port"
      fi
    '';
  };
  vpnNamespaces.proton = {
    enable = true;
    wireguardConfigFile = "/data/.secret/vpn/purmamarca-NL-749.conf";
    accessibleFrom = [
      "192.168.100.0/24"
      "100.100.0.0/16"
      "127.0.0.1/32"
    ];

    # Make the WebUI accessible outside the namespace
    portMappings = [
      {
        from = 9091;
        to = 9091;
      }
    ];
  };

  systemd.services.transmission = {
    # Add systemd service to VPN network namespace
    vpnConfinement = {
      enable = true;
      vpnNamespace = "proton";
    };
    # Wait for drive to be mounted
    unitConfig.RequiresMountsFor = "/media/media-store";
  };

  # Ensure the VPN namespace service also waits for the mount if the config is there
  systemd.services.proton.unitConfig.RequiresMountsFor = "/media/media-store";

  # media center: collect, manage, and stream media
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "media";
    # port: 8096;
  };
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg

    # network tools
    net-tools
    libnatpmp # natpmp
    tcpdump
  ];

  # indexer manager
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    # port: 9696;
  };

  # movies
  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    # port: 7878;
  };

  # TV series
  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    # port: 8989;
  };

  # music
  services.lidarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    # port: 8686;
  };

  # books
  services.readarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    # port: 8787;
  };

  # subtitles
  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    # port: 6767;
  };

  # user management
  services.seerr = {
    enable = true;
    openFirewall = true;
    # port: 5055;
  };

  age.secrets.netbird_purmamarca_setup_key = {
    file = ../../security/secrets/netbird_purmamarca_setup_key.age;
    owner = "netbird-wt0";
    group = "netbird-wt0";
    mode = "0440";
  };
  services.netbird.clients.wt0 = {
    environment = {
      # Forces the client to communicate with the self-hosted control plane
      NB_MANAGEMENT_URL = "https://vpn.woile.dev";
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
      setupKeyFile = config.age.secrets.netbird_purmamarca_setup_key.path;
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

  fileSystems = {
    # Mount the external drive with 5TB
    "/media/media-store" = {
      device = "/dev/disk/by-uuid/000D-92D4"; # TODO: Place the correct one here
      fsType = "exfat";
      options = [
        "defaults"
        "nofail" # Prevent system from failing if this drive doesn't mount
        "gid=media" # for non-root access
        "dmask=007" # Set directory permissions to 770 (rwxrwx---) excluding execute for others
        "fmask=117" # not having everything be executable
      ];
    };
  };

  users.users.woile.extraGroups = [ "media" ];
  users.groups.media = { };
}
