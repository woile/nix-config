{
  description = "My nix config";

  inputs = {
    # system packages for nixos
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    # user packages and dotfiles
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list where available
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      home-manager,
      ...
    }:
    # https://flake.parts/
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            name = "dev";
            buildInputs = [
              pkgs.just
            ];

            shellHook = ''
              echo "woile nix config"
              just --list
            '';
          };
        };
      flake = {
        templates = {
          devshell = {
            path = ./templates/devshell;
            description = "A simple nix shell for development";
          };
        };
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem (
          import ./hosts/nixos/system.nix {
            home-manager = home-manager;
          }
        );
        specialArgs = { inherit inputs; };
      };
    };
}
