# apply the configuration
rebuild:
	sudo nixos-rebuild switch --flake .

# rebuild but keep the old generation until reboot
rebuild__boot:
	sudo nixos-rebuild boot --flake .

# update the lock
update:
	nix flake update

# initialise home-manager on a linux host
init__home-manager host='woile-ubuntu':
	nix run home-manager/master -- init --switch --flake ".#{{host}}"

# build host with only home-manager
rebuild__home-manager host='woile-ubuntu':
	nix run home-manager/master -- switch -b backup --flake ".#{{host}}"
