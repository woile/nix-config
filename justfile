# apply the configuration
rebuild:
	sudo nixos-rebuild switch --flake .

# rebuild but keep the old generation until reboot
rebuild__boot:
	sudo nixos-rebuild boot --flake .

# update the lock
update:
	nix flake update