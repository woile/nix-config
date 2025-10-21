# switch to a new generation (recommended after setup)
switch:
    nh os switch .

# apply the configuration
rebuild:
	sudo nixos-rebuild switch --show-trace --flake .

# rebuild but keep the old generation until reboot
rebuild__boot:
	sudo nixos-rebuild boot --flake .

# update the lock
update input='':
	nix flake update {{input}}

# initialise home-manager on a linux host
init__home-manager host='woile-ubuntu':
	nix run home-manager/master -- init --switch --flake ".#{{host}}"

# build host with only home-manager
rebuild__home-manager host='woile-ubuntu':
	nix run home-manager/master -- switch -b backup --flake ".#{{host}}"

generations__home-manager:
	home-manager generations

generations_expire__home-manager host='woile-ubuntu':
	home-manager expire-generations "-7 days" --flake ".#{{host}}"
