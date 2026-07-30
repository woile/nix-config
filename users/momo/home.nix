{ pkgs, ... }:
{
  home.stateVersion = "26.11";
  home.username = "momo";
  home.homeDirectory = "/home/momo";

  services.kdeconnect.enable = true;
  programs.fd = {
    enable = true;
  };
  programs.helix = {
    enable = true;
    defaultEditor = true;
  };
  programs.starship.enable = true;

  programs.firefox.enable = true;
  programs.firefox.nativeMessagingHosts = [
    pkgs.firefoxpwa
    pkgs.kdePackages.plasma-browser-integration
  ];

}
