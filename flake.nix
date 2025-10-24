{
  description = "My nix config";

  inputs = {
    # system packages for nixos
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    # user packages and dotfiles
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Use system packages list where available
    };

    ## Packages

    temporis = {
      url = "github:reciperium/temporis";
      inputs.nixpkgs.follows = "nixpkgs";
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
      # imports = [
      #       # Import home-manager's flake module
      #       inputs.home-manager.flakeModules.home-manager
      #   ];

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
            description = "A basic nix shell for development";
          };
          rust-shell = {
            path = ./templates/rust-shell;
            description = "A basic nix shell for rust development";
          };
        };
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem (
          import ./hosts/nixos/system.nix {
            home-manager = home-manager;
            inputs = inputs;
          }
        );
        nixosConfigurations.aconcagua = nixpkgs.lib.nixosSystem (
          import ./hosts/aconcagua/system.nix {
            home-manager = home-manager;
            inputs = inputs;
          }
        );
        # id: new-cfg-targets
        homeConfigurations = {
          woile-ubuntu = import ./hosts/ubuntu/system.nix {
            home-manager = home-manager;
            nixpkgs = nixpkgs;
            inputs = inputs;
          };
        };
        specialArgs = { inherit inputs; };
      };
    };
}
