{ pkgs, ... }:
{
  imports = [
    ../../users/woile/home.nix
  ];

  home.packages = with pkgs; [
    google-chrome
    finamp
  ];
  # home.shellAliases = {};
}
