# home-manager config for this host
{ pkgs, ... }:
{
  imports = [
    ../../users/woile/home.nix
  ];

  home.packages = with pkgs; [
    vscode-fhs # FHS variant, which allows installing extensions
    google-chrome
    pinta
    krita
  ];
  home.shellAliases = {
    "kde-restart" = "plasmashell --replace";
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
}
