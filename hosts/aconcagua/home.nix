{ pkgs, ... }:
{
  imports = [
    ../../users/woile/home.nix
    ../../profiles/development
  ];

  home.packages = with pkgs; [
    chromium
    finamp
    jellyfin-desktop
    mistral-rs

    (llama-cpp-rocm.overrideAttrs (oldAttrs: {
      DGFX_VERSION = "11.5.1";
      # FORCE_REBUILD = builtins.currentTime;
      # Adding a dummy attribute forces a local build
      passthru = (oldAttrs.passthru or { }) // {
        forceRebuild = 1;
      };
    }))

  ];
  # home.shellAliases = {};
}
