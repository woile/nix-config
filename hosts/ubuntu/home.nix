{ pkgs, lib, ... }:
{
  # programs.zed-editor.enable = lib.mkForce false;
  imports = [
    ../../users/woile/home.nix
  ];
}
