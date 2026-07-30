{ pkgs, ... }:
{
  users.users.momo = {
    isNormalUser = true;
    description = "Momo";
    extraGroups = [
      "networkmanager"
      "video"
      "audio"
    ];
    packages = with pkgs; [
      # User-specific packages can be added here
    ];
  };

  home-manager.users.momo = import ./home.nix;
}
