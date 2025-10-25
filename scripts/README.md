# Scripts

## Onboarding a new laptop

Run from the root of the repository:

```sh
./scripts/init-nixos-flake.sh <hostname>
```

## Reverting in case of issues

If something goes wrong, you can revert the changes made by the script:

```sh
./scripts/revert-nixos-flake.sh <hostname>
```
