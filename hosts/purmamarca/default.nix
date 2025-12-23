# Membrane connecting everything together
{
  home-manager,
  inputs,
  vpn-confinement,
  ouro,
  ...
}:
{
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    vpn-confinement.nixosModules.default
    ouro.nixosModules.default
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.woile = import ./home.nix;
    }
  ];
  specialArgs = { inherit inputs; };
}
