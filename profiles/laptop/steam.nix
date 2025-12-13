{ pkgs, ... }:
{
  # does some system configuration that Home Manager doesn’t have the privileges to do
  programs.steam = {
    enable = true;
    # Open ports in the firewall for Steam Remote Play
    remotePlay.openFirewall = true;
    # Open ports in the firewall for Source Dedicated Server
    dedicatedServer.openFirewall = true;
    # Open ports in the firewall for Steam Local Network Game Transfers
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
  programs.steam.protontricks.enable = true;

  # GameMode
  # Add to game launch options in steam:
  # gamemoderun %command%
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # For steam games
    protonup-qt
    mangohud
  ];
}
