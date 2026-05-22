# Membrane connecting everything together
{ inputs, ... }:
{
  system = "x86_64-linux";
  modules = [
    inputs.agenix.nixosModules.default
    # inputs.disko.nixosModules.disko
    ./configuration.nix
    ./hardware-vm.nix
  ];
  specialArgs = { inherit inputs; };
}
