# nix-config

> This repository contains my personal Nix configuration files.

## Hosts

> Host running nixos

### First run

```sh
sudo nixos-rebuild switch --flake .
direnv allow
```

### Update

> At this point direnv and just will be installed

```sh
just update
just rebuild
```

## Home manager

> Hosts running other distro with home-manager

### First run

Initialize
```sh
nix run home-manager/master -- init --switch --flake ".#woile-ubuntu"
direnv allow
```

### Update

> At this point direnv and just will be installed

```sh
just update
just rebuild__home-manager
```
