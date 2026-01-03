# nix-config

> This repository contains my personal Nix configuration files.

## Structure

- `flake.nix`: The main Nix flake file.
- `hardware`: Hardware configuration files.
- [hosts](./hosts): Host-specific configuration files.
- [profiles](./profiles): Profile-specific configuration files (e.g: laptop, developer).
- `programs`: Program-specific configuration files, doesn't involve nix (e.g: zeditor).
- `users`: User-specific configuration files.
- [templates](./templates): Reusable templates for coding projects.
- [scripts](./scripts): Scripts for managing the configuration.

This repository doesn't do any kind of magic, it's mainly for structure and organization.
I try to keep standards, conventions and simplicity. A few values are repeated here and there.

```sh
.
├── flake.nix
├── hardware/
├── hosts/                     # where the combination that makes the actual host happen
│   └── <hostname>/            # the hostname of the machine
│       ├── configuration.nix  # a nixos configuration.nix (without it, it's for home-manager)
│       ├── home.nix           # a home-manager configuration.nix
│       └── default.nix        # glues everything together and it's used by flake.nix
├── justfile                   # reusable commands
├── modules/                   # custom NixOS modules 
├── profiles/                  # allows grouping configurations together
│   └── laptop/                # example profile
│       ├── configuration.nix  # indicates that it's for a NixOs host
│       └── default.nix        # glues everything together and it's used by flake.nix
├── programs/
├── scripts/
├── templates/
└── users
    └── <username>
        ├── home.nix           # home-manager configuration.nix
        └── user.nix           # nixos user configuration.nix
```

### First run

```sh
sudo nixos-rebuild switch --flake .
direnv allow
```

### Update

> At this point direnv and just will be installed

```sh
just update
just switch
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
