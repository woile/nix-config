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

    # disk management
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # secret management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      home-manager,
      vpn-confinement,
      self,
      deploy-rs,
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
          deploy-rs = inputs'.deploy-rs.packages.deploy-rs;
        in
        {
          devShells.default = pkgs.mkShell {
            name = "dev";
            buildInputs = with pkgs; [
              just
              terraform-docs
              jq
              opentofu
              yq-go
              # scaleway-cli
              tofu-ls

              deploy-rs
            ];

            shellHook = ''
              echo "woile nix config"
              just --list --list-submodules
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
          }
        );
        nixosConfigurations.aconcagua = nixpkgs.lib.nixosSystem (
          import ./hosts/aconcagua {
            home-manager = home-manager;
            inputs = inputs;
          }
        );
        nixosConfigurations.amaru = nixpkgs.lib.nixosSystem (
          import ./hosts/amaru {
            inputs = inputs;
          }
        );
        nixosConfigurations.tacuarita = nixpkgs.lib.nixosSystem (
          import ./hosts/tacuarita {
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

        deploy.nodes = {
          purmamarca = {
            hostname = "purmamarca.vpn.woile.eu";
            sshUser = "root";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.purmamarca;
            };
          };
          aconcagua = {
            hostname = "aconcagua";
            sshUser = "root";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.aconcagua;
            };
          };
          amaru = {
            hostname = "amaru.vpn.woile.eu";
            sshUser = "root";
            confirmTimeout = 120;
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.amaru;
            };
          };
          tacuarita = {
            hostname = "tacuarita.vpn.woile.eu";
            sshUser = "root";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.tacuarita;
            };
          };
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

        specialArgs = { inherit inputs; };
      };
    };
}
