{ pkgs, ... }:
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
    extraServiceFiles = {
      "media-http" = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">media on %h</name>
          <service>
            <type>_http._tcp</type>
            <port>8096</port>
          </service>
        </service-group>
      '';
      "feed-http" = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">feed on %h</name>
          <service>
            <type>_http._tcp</type>
            <port>5055</port>
          </service>
        </service-group>
      '';
      "prowlarr-http" = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">prowlarr on %h</name>
          <service>
            <type>_http._tcp</type>
            <port>9696</port>
          </service>
        </service-group>
      '';
      "radarr-http" = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">radarr on %h</name>
          <service>
            <type>_http._tcp</type>
            <port>7878</port>
          </service>
        </service-group>
      '';
      "sonarr-http" = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">sonarr on %h</name>
          <service>
            <type>_http._tcp</type>
            <port>8989</port>
          </service>
        </service-group>
      '';
      "lidarr-http" = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">lidarr on %h</name>
          <service>
            <type>_http._tcp</type>
            <port>8686</port>
          </service>
        </service-group>
      '';
      "jackett-http" = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">jackett on %h</name>
          <service>
            <type>_http._tcp</type>
            <port>9117</port>
          </service>
        </service-group>
      '';
    };
  };

  # Torrenting client
  services.transmission = {
    enable = true;
    openFirewall = true;
    group = "media";
    package = pkgs.transmission_4;
    settings = {
      download-dir = "/media/media-store/media-center/transmission/download";
      incomplete-dir = "/media/media-store/media-center/transmission/.incomplete";
    };
  };

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
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
    # port: 5055;
  };

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
