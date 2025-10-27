{ pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "media";
  };
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
  services.transmission = {
    enable = true;
    openFirewall = true;
    group = "media";
    settings = {
      download-dir = "/media/media-store/media-center/transmission/download";
      incomplete-dir = "/media/media-store/media-center/transmission/.incomplete";
    };
  };
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish.enable = true;
    publish.addresses = true;
    publish.workstation = true;
  };
  # indexer manager
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  # movies
  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  # TV series
  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  # music
  services.lidarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  # books
  services.readarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  # subtitles
  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  # user management
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  fileSystems = {
    "/media/media-store" = {
      device = "/dev/sda2"; # TODO: Place the correct one here
      fsType = "exfat";
      options = [
        "defaults"
        "gid=media" # for non-root access
        "dmask=007"
        "fmask=117" # not having everything be executable
      ];
    };
  };

  users.user.woile.extraGroups = [ "media" ];
}
