# home-manager config for this host
{ pkgs, ... }:
{
  imports = [
    ../../users/woile/home.nix
  ];

  home.packages = with pkgs; [
    vscode-fhs # FHS variant, which allows installing extensions
    google-chrome
  ];
}
