# Infrastructure

This is terraform, it doesn't use nix, at least not yet.

Takes care of deploying VM in the cloud and then installing nix on them (via `nixos-bite`)

## Init

```sh
just init
```

## Deploy

```sh
just plan
just apply
```

## Destroy Server

```sh
just destroy-server
```

## Upgrade Deps

```sh
just upgrade
```
