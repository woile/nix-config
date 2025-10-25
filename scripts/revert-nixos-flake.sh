#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p dmidecode sd
# Does its best to revert the changes made by the script init-nixos-flake.sh
set -e

sudo -v
NEW_HOSTNAME=${1:-$(hostname)}
MANUFACTURER=$(sudo dmidecode -s system-manufacturer | tr '[:upper:]' '[:lower:]')
PRODUCT_NAME=$(sudo dmidecode -s system-product-name | tr '[:upper:]' '[:lower:]')

sudo mv /etc/nixos/configuration.nix.original /etc/nixos/configuration.nix
sudo mv /etc/nixos/hardware-configuration.nix.original /etc/nixos/hardware-configuration.nix

CONFIG_TARGET_PATH="hosts/$NEW_HOSTNAME"
HW_CONFIG_PATH="hardware/$MANUFACTURER/$PRODUCT_NAME"

echo "Removing $HW_CONFIG_PATH ..."
rm -rf "$HW_CONFIG_PATH"
echo "Removing $CONFIG_TARGET_PATH ..."
rm -rf "$CONFIG_TARGET_PATH"

echo "Reverting git changes ..."
git checkout -f flake.nix

echo "Done"
