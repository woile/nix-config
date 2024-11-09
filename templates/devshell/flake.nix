{
  description = "Frontend app for reciperium";

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
            name = "mm";
            buildInputs = [
              pkgs.just
            ];

            shellHook = ''
              just --list
            '';
          };

        };
    };
}
