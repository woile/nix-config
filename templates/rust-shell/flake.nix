{
  description = "A development shell for rust";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
        { pkgs, inputs', ... }:
        {
          devShells.default = pkgs.mkShell {
            name = "dev";

            # Available packages on https://search.nixos.org/packages
            buildInputs = with pkgs; [
              just
              inputs'.fenix.packages.stable.toolchain
            ];

            shellHook = ''
              echo "Welcome to the rust devshell!"
            '';
          };
        };
    };
}
