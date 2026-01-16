{ pkgs, ... }:
{
  imports = [
    ../../users/woile/home.nix
  ];

  home.packages = with pkgs; [
    chromium
    finamp
  ];
  # home.shellAliases = {};
}
