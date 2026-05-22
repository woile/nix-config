# Use this with NixOS
{ pkgs, lib, ... }:

let
  sshPubFiles = lib.filterAttrs (k: v: v == "regular" && lib.hasSuffix ".pub" k) (
    builtins.readDir ../../security/authorized_keys
  );
  authorizedKeys = lib.mapAttrsToList (
    k: v: builtins.readFile "${../../security/authorized_keys}/${k}"
  ) sshPubFiles;
in
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
      "podman"
      "tss" # Trusted Computing Group Software Stack
    ];
    packages = with pkgs; [
      vim
      rng-tools
      #  thunderbird
    ];
    openssh.authorizedKeys.keys = authorizedKeys;
  };
}
