{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    inputs@{
      flake-parts,
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
              echo "Welcome to santi's nix config"
              # just --list
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
      };
    };
}
