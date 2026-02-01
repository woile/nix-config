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

    ## Other

    temporis = {
      url = "github:reciperium/temporis";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VPN
    vpn-confinement = {
      url = "github:Maroka-chan/VPN-Confinement";
    };
    ouro = {
      url = "github:reo101/ouro";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      home-manager,
      vpn-confinement,
      ouro,
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
            buildInputs = with pkgs; [
              just
              terraform-docs
              jq
              opentofu
              yq-go
              scaleway-cli
              tofu-ls
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
          rust-pkgs-shell = {
            path = ./templates/rust-pkgs-shell;
            description = "A nix shell and packages for rust development";
          };
        };
        nixosConfigurations.purmamarca = nixpkgs.lib.nixosSystem (
          import ./hosts/purmamarca {
            home-manager = home-manager;
            inputs = inputs;
            vpn-confinement = vpn-confinement;
            ouro = ouro;
          }
        );
        nixosConfigurations.aconcagua = nixpkgs.lib.nixosSystem (
          import ./hosts/aconcagua {
            home-manager = home-manager;
            inputs = inputs;
          }
        );
        # id: new-cfg-targets
        homeConfigurations = {
          woile-ubuntu = import ./hosts/ubuntu {
            home-manager = home-manager;
            nixpkgs = nixpkgs;
            inputs = inputs;
          };
        };
        specialArgs = { inherit inputs; };
      };
    };
}
