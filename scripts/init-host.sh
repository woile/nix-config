#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p sd
# Initialize a new host
#
# Run this script from this project's root directory.
#
# Usage:
#   ./scripts/init-host.sh <hostname> <manufacturer> <product_name> <system?>
#
# Example:
#   ./scripts/init-host.sh tacuarita "acemagic" "vista-mini"
set -e
echo "Performing checks..."
NEW_HOSTNAME=${1:-$(hostname)}

# If NEW_HOSTNAME folder exists, then exit
if [ -d "./hosts/$NEW_HOSTNAME" ]; then
    echo "Hostname folder under ./hosts already exists"
    exit 1
fi

echo "Retrieving information..."
# New hostname should read from the first argument or default to the current hostname

echo ""
echo "##############################"
echo "##### SYSTEM INFORMATION #####"
echo "##############################"
echo "Hostname: $NEW_HOSTNAME"

# retrieve manufacturer and product name and lowercase it
MANUFACTURER=${2}
PRODUCT_NAME=${3}
echo "Manufacturer: $MANUFACTURER"
echo "Product Name: $PRODUCT_NAME"

# get current system value using nix
# $(nix-instantiate --eval --expr 'builtins.currentSystem')
SYSTEM=${4:-"x86_64-linux"}
echo "System: $SYSTEM"

CONFIG_TARGET_PATH="hosts/$NEW_HOSTNAME"
HW_CONFIG_PATH="hardware/$MANUFACTURER/$PRODUCT_NAME"

echo "Creating new system directories..."
mkdir -p "$CONFIG_TARGET_PATH"
mkdir -p "$HW_CONFIG_PATH"

echo "Init configuration files..."
touch "$CONFIG_TARGET_PATH/configuration.nix"
touch "$HW_CONFIG_PATH/hardware-configuration.nix"

echo "Creating home.nix..."
# Add a basic home for specific to the new host ./home.nix
cat <<EOF > "$CONFIG_TARGET_PATH/home.nix"
{ pkgs, ... }:
{
  imports = [
    ../../users/woile/home.nix
  ];

  # home.packages = with pkgs; [];
  # home.shellAliases = {};
}
EOF

echo "Creating default.nix..."
# Add a `default.nix` file for the new host
cat <<EOF > "$CONFIG_TARGET_PATH/default.nix"
# Membrane connecting everything together
{ home-manager, inputs, ... }:
{
  system = $CURRENT_SYSTEM;
  modules = [
    ./configuration.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.woile = import ./home.nix;
    }
  ];
  specialArgs = { inherit inputs; };
}
EOF


# Store multiline string in variable
NEW_NIXOS_CONFIG=$(cat <<EOM
nixosConfigurations.$NEW_HOSTNAME = nixpkgs.lib.nixosSystem (
          import ./$CONFIG_TARGET_PATH {
            home-manager = home-manager;
            inputs = inputs;
          }
        );
EOM
)

echo "Adding host '$NEW_HOSTNAME' to flake.nix..."
# Append "foo" before the line # id: new-cfg-targets in flake.nix
sd "# id: new-cfg-targets" "$NEW_NIXOS_CONFIG\n        # id: new-cfg-targets" "./flake.nix"

echo "Migration completed."
echo ""
echo "Consider adding a user and profile:"
echo "    imports = ["
echo "        # other configs before"
echo "        ../../users/woile/user.nix"
echo "        ../../profiles/laptop"
echo "    ]"
echo ""
echo "Don't forget to add the 'nix.settings.experimental-features' to the 'configuration.nix' if necessary!"
echo ""
echo "Run this command to apply the changes on the next boot:"
echo "    git add $CONFIG_TARGET_PATH $HW_CONFIG_PATH flake.nix"
echo "    sudo nixos-rebuild boot --flake \".#$NEW_HOSTNAME\""
