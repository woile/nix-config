# Profiles

Profiles group configuration "logically" together.

My convention is:

- should have a `default.nix` file to easily import the profile, this doesn't mean that a single file from the profile cannot be used
- if it has a `configuration.nix` file, then it's a configuration for **NixOS**
- if it has a `home.nix` file, then it's a configuration for **Nix Home Manager**
- if it has a `darwin.nix` file, then it's a configuration for **NixOS on macOS** only
