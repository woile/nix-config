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
      # "stremio-shell"
      # "stremio-server"
      "windsurf"
      "cursor"
      "code"
      "vscode"
      "textual-speedups"
    ];
  # programs.zed-editor.enable = lib.mkForce false;
  imports = [
    ../../users/woile/home.nix
  ];

  home.packages = with pkgs; [
    kubectl
    kubernetes-helm
    k9s
    rancher
    kubeseal
    bashInteractive
  ];

  # load home-manager untracked functions
  programs.bash.bashrcExtra = ''
    if [ -f ~/.extrarc ]; then
      source ~/.extrarc
    fi
  '';
  # Disable signing in this vm
  programs.git.signing.signByDefault = lib.mkForce false;
}
