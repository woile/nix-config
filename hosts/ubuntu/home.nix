{ pkgs, lib, ... }:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "steam"
      "steam-run"
      "steam-original"
      "obsidian"
      "google-chrome"
      "stremio-shell"
      "stremio-server"
      "windsurf"
      "cursor"
      "code"
      "vscode"
    ];
  # programs.zed-editor.enable = lib.mkForce false;
  imports = [
    ../../users/woile/home.nix
  ];
}
