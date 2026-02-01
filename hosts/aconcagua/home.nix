{ pkgs, ... }:
{
  imports = [
    ../../users/woile/home.nix
  ];

  home.packages = with pkgs; [
    chromium
    finamp
    jellyfin-desktop
    mistral-rs
  ];
  # home.shellAliases = {};
}
