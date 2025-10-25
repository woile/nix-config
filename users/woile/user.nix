# Use this with NixOS
{ pkgs, ... }:
{
  users.users.woile = {
    isNormalUser = true;
    description = "Santiago Fraire";
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
      "adbusers"
      "libvirtd"
    ];
    packages = with pkgs; [
      vim
      rng-tools
      #  thunderbird
    ];
  };
}
