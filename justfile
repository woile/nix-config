hostname := `hostname`

# switch to a new generation (recommended after setup)
switch host=hostname:
    nh os switch --show-trace --ask --hostname "{{ host }}" .

# switch to a new generation on a remote host
[arg('host', pattern='purmamarca|aconcagua')]
remote-switch host=hostname:
    nh os switch --show-trace --ask --build-host "{{ host }}.local" --target-host "{{ host }}.local" --hostname "{{ host }}" .

# create new generation for next boot
boot host=hostname:
    nh os boot --show-trace --ask --hostname "{{ host }}" .

# apply the configuration
rebuild host=hostname:
    sudo nixos-rebuild switch --show-trace --flake ".#{{ host }}"

# rebuild but keep the old generation until reboot
rebuild__boot host=hostname:
    sudo nixos-rebuild boot --show-trace --flake ".#{{ host }}"

# update the lock
update input='':
    nix flake update {{ input }}

# initialise home-manager on a linux host
init__home-manager host='woile-ubuntu':
    nix run home-manager/master -- init --switch --flake ".#{{ host }}"

# build host with only home-manager
rebuild__home-manager host='woile-ubuntu':
    nix run home-manager/master -- switch -b backup --flake ".#{{ host }}"

generations__home-manager:
    home-manager generations

generations_expire__home-manager host='woile-ubuntu':
    home-manager expire-generations "-7 days" --flake ".#{{ host }}"

store__optimize:
    nix-store --optimise --log-format bar-with-logs
