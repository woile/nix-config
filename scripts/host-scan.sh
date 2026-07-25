#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p dmidecode sd
#
# Scan a host for information
#
# # Usage:
#    scp ./scripts/host-scan.sh user@remote_host:host-scan.sh
#   ./scripts/host-scan.sh

HOSTNAME=${1:-$(hostname)}
# retrieve manufacturer and product name and lowercase it
MANUFACTURER=$(sudo dmidecode -s system-manufacturer | tr '[:upper:]' '[:lower:]')
PRODUCT_NAME=$(sudo dmidecode -s system-product-name | tr '[:upper:]' '[:lower:]')

echo ""
echo "##############################"
echo "##### SYSTEM INFORMATION #####"
echo "##############################"
echo "Hostname: $HOSTNAME"
echo "Manufacturer: $MANUFACTURER"
echo "Product Name: $PRODUCT_NAME"

CURRENT_SYSTEM=$(nix-instantiate --eval --expr 'builtins.currentSystem')
echo "Current System: $CURRENT_SYSTEM"
