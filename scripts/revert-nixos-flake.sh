#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p dmidecode sd
set -e
sudo -v
NEW_HOSTNAME=${1:-$(hostname)}

sudo mv /etc/nixos/configuration.nix.original /etc/nixos/configuration.nix
sudo mv /etc/nixos/hardware-configuration.nix.original /etc/nixos/hardware-configuration.nix
rm -rf hardware/aistone
rm -rf "hosts/$NEW_HOSTNAME"
git checkout -f flake.nix
