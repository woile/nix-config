{ pkgs, ... }:
{
  imports = [
    ../../users/woile/home.nix
    ../../profiles/development
  ];

  home.packages = with pkgs; [
    chromium
    finamp
    jellyfin-desktop
    mistral-rs
  ];
}
