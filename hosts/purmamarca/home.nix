# home-manager config for this host
{ pkgs, ... }:
{
  imports = [
    ../../users/woile/home.nix
  ];

  home.packages = with pkgs; [
    jellyflix
    delfin
  ];
  home.shellAliases = {
    "kde-restart" = "plasmashell --replace";
  };

  xdg.desktopEntries.jellyfin-desktop = {
    name = "Jellyfin Desktop";
    genericName = "Media Center";
    exec = "${pkgs.google-chrome}/bin/google-chrome-stable --app=http://localhost:8096 --start-fullscreen";
    terminal = false;
    type = "Application";
    categories = [
      "AudioVideo"
      "Video"
    ];
  };

  programs.chromium = {
    enable = true;
    nativeMessagingHosts = [
      pkgs.kdePackages.plasma-browser-integration
    ];
  };
}
