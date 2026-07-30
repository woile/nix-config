# Membrane connecting everything together
{ home-manager, inputs, ... }:
{
  system = "x86_64-linux";
  modules = [
    inputs.agenix.nixosModules.default
    home-manager.nixosModules.home-manager
    ./configuration.nix
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.woile = {
        imports = [
          ../../users/woile/home.nix
        ];
      };
    }
  ];
  specialArgs = { inherit inputs; };
}
