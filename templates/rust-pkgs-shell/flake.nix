{
  description = "A rust flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
    };
  };
  outputs =
    inputs@{
      flake-parts,
      crane,
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
        let
          rustChannel = "stable";
          fenix = inputs'.fenix.packages;
          rustToolchain = (
            fenix.combine [
              fenix.${rustChannel}.toolchain

              # https://doc.rust-lang.org/rustc/platform-support.html
              # For more targets add:
              # fenix.targets.aarch64-linux-android."${rustChannel}".rust-std
              # fenix.targets.x86_64-linux-android."${rustChannel}".rust-std
            ]
          );
          craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;
        in
        {
          # Build the binary package with:
          # nix build .
          # If you want to build a specific package, use:
          # nix build .#<package-name>
          packages.default = craneLib.buildPackage {
            src = ./.;
          };

          # Default shell opened with `nix develop`
          devShells.default = pkgs.mkShell {
            name = "dev";

            # Available packages on https://search.nixos.org/packages
            buildInputs = with pkgs; [
              just
              rustToolchain
            ];

            shellHook = ''
              echo "Welcome to the rust devshell!"
            '';
          };
        };
    };
}
