#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p dmidecode sd
# Given a normal NixOS installation, migrate it to a flake-based configuration.
#
# Run this script from this project's root directory.
#
# Usage:
#   ./scripts/init-nixos-flake.sh <hostname>
#
# Example:
#   ./scripts/init-nixos-flake.sh aconcagua
set -e
echo "Performing checks..."
NEW_HOSTNAME=${1:-$(hostname)}

# If NEW_HOSTNAME folder exists, then exit
if [ -d "./hosts/$NEW_HOSTNAME" ]; then
    echo "Hostname folder under ./hosts already exists"
    exit 1
fi

# If /etc/nixos/configuration.nix or /etc/nixos/hardware-configuration.nix
# do not exists,
# then it means the initialization already happened, and should not be done again.
if [ ! -f "/etc/nixos/configuration.nix" ] && [ ! -f "/etc/nixos/hardware-configuration.nix" ]; then
    echo "Migration to flake-based configuration already done"
    exit 1
fi

echo "Requesting sudo privileges..."
# gain sudo privileges for the rest of the script
sudo -v

echo "Retrieving information..."
# New hostname should read from the first argument or default to the current hostname

echo ""
echo "##############################"
echo "##### SYSTEM INFORMATION #####"
echo "##############################"
echo "Hostname: $NEW_HOSTNAME"

# retrieve manufacturer and product name and lowercase it
MANUFACTURER=$(sudo dmidecode -s system-manufacturer | tr '[:upper:]' '[:lower:]')
PRODUCT_NAME=$(sudo dmidecode -s system-product-name | tr '[:upper:]' '[:lower:]')
echo "Manufacturer: $MANUFACTURER"
echo "Product Name: $PRODUCT_NAME"

# get current system value using nix
CURRENT_SYSTEM=$(nix-instantiate --eval --expr 'builtins.currentSystem')
echo "Current System: $CURRENT_SYSTEM"

CONFIG_TARGET_PATH="hosts/$NEW_HOSTNAME"
HW_CONFIG_PATH="hardware/$MANUFACTURER/$PRODUCT_NAME"

echo ""
echo "##########################"
echo "##### FILE LOCATIONS #####"
echo "##########################"
echo "M hardware-configuration.nix -> $HW_CONFIG_PATH/hardware-configuration.nix"
echo "MU configuration.nix -> $CONFIG_TARGET_PATH/configuration.nix"
echo "+ $CONFIG_TARGET_PATH/system.nix"
echo "+ $CONFIG_TARGET_PATH/home.nix"
echo "U flake.nix"
echo ""

# Request user input for confirmation
read -p "Are you sure you want to proceed with the migration? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Migration aborted."
    exit 1
fi

echo "Creating new system directories..."
mkdir -p "$CONFIG_TARGET_PATH"
mkdir -p "$HW_CONFIG_PATH"

echo "Copying configuration files..."
cp /etc/nixos/configuration.nix "$CONFIG_TARGET_PATH/configuration.nix"
cp /etc/nixos/hardware-configuration.nix "$HW_CONFIG_PATH/hardware-configuration.nix"

echo "Updating configuration.nix..."
# replace "./hardware-configuration.nix" with "../../$HW_CONFIG_PATH/hardware-configuration.nix"
sd "./hardware-configuration.nix" "../../$HW_CONFIG_PATH/hardware-configuration.nix" "$CONFIG_TARGET_PATH/configuration.nix"

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

echo "Creating system.nix..."
# Add a `system.nix` file for the new host
cat <<EOF > "$CONFIG_TARGET_PATH/system.nix"
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
          import ./$CONFIG_TARGET_PATH/system.nix {
            home-manager = home-manager;
            inputs = inputs;
          }
        );
EOM
)

echo "Adding host '$NEW_HOSTNAME' to flake.nix..."
# Append "foo" before the line # id: new-cfg-targets in flake.nix
sd "# id: new-cfg-targets" "$NEW_NIXOS_CONFIG\n        # id: new-cfg-targets" "./flake.nix"

echo "Backing up original files..."
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.original
sudo mv /etc/nixos/hardware-configuration.nix /etc/nixos/hardware-configuration.nix.original

echo "Migration completed."
echo "Don't forget to add the 'nix.settings.experimental-features' to the configuration.nix!"
echo ""
echo "Run this command to apply the changes on the next boot:"
echo "    git add $CONFIG_TARGET_PATH $HW_CONFIG_PATH flake.nix"
echo "    sudo nixos-rebuild boot --flake \".#$NEW_HOSTNAME\""
