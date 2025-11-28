# home-manager config for this host
{ pkgs, ... }:
{
  imports = [
    ../../users/woile/home.nix
  ];

  home.packages = with pkgs; [
    vscode-fhs # FHS variant, which allows installing extensions
  ];
  home.shellAliases = {
    "kde-restart" = "plasmashell --replace";
  };

  xdg.desktopEntries.jellyfin-desktop = {
    name = "Jellyfin Desktop";
    genericName = "Media Center";
    exec = "chromium --app=http://localhost:8096 --start-fullscreen";
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
