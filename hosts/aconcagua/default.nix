# Membrane connecting everything together
{ home-manager, inputs, ... }:
{
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    inputs.agenix.nixosModules.default
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.woile = {
        imports = [
          ../../users/woile/home.nix
          ../../profiles/development
        ];
      };
    }
  ];
  specialArgs = { inherit inputs; };
}
