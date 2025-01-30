{ pkgs, ... }:
{
  home.username = "woile";
  home.homeDirectory = "/home/woile";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.direnv = {
    enable = true;
    config.global = {
      # Make direnv messages less verbose
      hide_env_diff = true;
    };
  };
  programs.bash.enable = true;
  programs.git.enable = true;
  programs.eza = {
    enable = true;
    icons = "auto";
  };
  programs.gpg.enable = true;
  programs.starship.enable = true;
  programs.firefox.enable = true;
  programs.poetry = {
    enable = true;
    settings = {
      virtualenvs.create = true;
      virtualenvs.in-project = true;
    };
  };

  home.packages = [
    pkgs.neofetch
    pkgs.nerdfonts # fonts with ligatures
    pkgs.uv # python package manager
    pkgs.python312
    pkgs.just
    pkgs.obsidian
    pkgs.gopass
    pkgs.gopass-jsonapi
    pkgs.google-chrome
    pkgs.stremio
    pkgs.spotify
    pkgs.systemctl-tui
  ];

  home.shellAliases = {
    ls = "exa -l";
  };

  fonts = {
    fontconfig = {
      enable = true;

      # defaultFonts = {
      #   serif = [
      #     "DejaVu Serif"

      #   ];
      #   sansSerif = [
      #     "DejaVu Sans"

      #   ];
      #   monospace = [ "DejaVu Sans Mono" ];
      #   emoji = [
      #     "Noto Color Emoji"
      #   ];
      # };
    };
  };

}
