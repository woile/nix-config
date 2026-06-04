export RULES := 'security/secrets.nix'

hostname := `hostname`

# Infrastructure recipes, use `just infra::<cmd>`
mod infra '.infra/justfile'

# switch to a new generation (recommended after setup)
[group("management")]
switch host=hostname:
    nh os switch --diff always --show-trace --ask --hostname "{{ host }}" .

# create new generation for next boot
[group("management")]
boot host=hostname:
    nh os boot --show-trace --ask --hostname "{{ host }}" .

# switch to a new generation on home-manager host
[group("management")]
home-switch host='woile-ubuntu':
    nh home switch --ask . -c "{{ host }}"

# apply the configuration
[group("management")]
rebuild host=hostname:
    sudo nixos-rebuild switch --show-trace --flake ".#{{ host }}"

# rebuild but keep the old generation until reboot
[group("management")]
rebuild__boot host=hostname:
    sudo nixos-rebuild boot --show-trace --flake ".#{{ host }}"

# update the lock
[group("maintenance")]
update input='':
    nix flake update {{ input }}

# initialise home-manager on a linux host
[group("setup")]
init__home-manager host='woile-ubuntu':
    nix run home-manager/master -- init --switch --flake ".#{{ host }}"

# build host with only home-manager
[group("management")]
rebuild__home-manager host='woile-ubuntu':
    nix run home-manager/master -- switch -b backup --flake ".#{{ host }}"

[group("maintenance")]
generations__home-manager:
    home-manager generations

# Expire old generations
[group("maintenance")]
generations_expire__home-manager host='woile-ubuntu':
    home-manager expire-generations "-7 days" --flake ".#{{ host }}"

# Optimize store
[group("maintenance")]
store__optimize:
    nix-store --optimise --log-format bar-with-logs

# clean up old generations and store
[group("maintenance")]
clean:
    nh clean all --keep 3  --keep-since 7d --ask

# Apply a new generation to a remote VM
[group("management")]
vm-switch host='amaru':
    #!/usr/bin/env sh
    IP=$(just infra::outputs | jq -r '.{{ host }}_ssh.value')
    nh os switch --show-trace --target-host "woile@[${IP}]" --hostname "{{ host }}" .

# Add agenix secret, do not include .age extension
[group('secrets')]
secret__add name:
    agenix -e 'security/secrets/{{ name }}.age'

# Re-encrypt secrets
[group('secrets')]
secret__rekey:
    agenix --rekey

# switch to a new generation on a remote host
[arg('host', pattern='purmamarca|aconcagua')]
[group("management")]
remote-switch host=hostname:
    nh os switch --show-trace --ask --target-host "{{ host }}.local" --hostname "{{ host }}" .

# create new generation on a remote host
[arg('host', pattern='purmamarca|aconcagua')]
[group("management")]
remote-boot host=hostname:
    nh os boot --diff always --show-trace --target-host "{{ host }}.local" --hostname "{{ host }}" .
