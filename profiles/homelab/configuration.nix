{ pkgs, ... }:
{

  # mDNS for local services discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
    publish.addresses = true;
    publish.workstation = true;
  };

  # Torrenting client
  services.transmission = {
    enable = true;
    openFirewall = true;
    group = "media";
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

  xdg.desktopEntries.jellyfin-desktop = {
    name = "Jellyfin Desktop";
    genericName = "Media Center";
    exec = "firefox --kiosk --new-window http://localhost:8096";
    terminal = false;
    type = "Application";
    categories = [
      "AudioVideo"
      "Video"
    ];
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
