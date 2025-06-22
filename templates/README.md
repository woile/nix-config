# Templates


### Basic dev shell

Apply to the current folder by running:

```sh
nix flake init -t github:woile/nix-config#devshell
```

### Rust dev shell

> WARNING: It only provides the shell commands (cargo, rust-analyzer, etc), not a way to build a package.
> This template is only useful to avoid installing rust globally.

```sh
nix flake init -t github:woile/nix-config#rust-shell
```

Manages toolchain using [fenix](https://github.com/nix-community/fenix)

### Rust packages and dev shell

Apply to the current folder by running:

```sh
nix flake init -t github:woile/nix-config#rust-pkgs-shell
```

Manages toolchain using [fenix](https://github.com/nix-community/fenix) and builds using [crane](https://github.com/ipetkov/crane/),
to avoid rebuilding each crate.
