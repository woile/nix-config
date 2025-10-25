{
  home-manager,
  nixpkgs,
  ...
}:
let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in

home-manager.lib.homeManagerConfiguration {
  pkgs = pkgs;
  modules = [
    ./home.nix
  ];
}
