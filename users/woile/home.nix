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
  programs.git = {
    enable = true;
    userName = "Santiago Fraire Willemoes";
    userEmail = "santiwilly@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
    delta.enable = true;
  };
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

  home.packages = with pkgs; [
    nerdfonts # fonts with ligatures
    uv # python package manager
    python312
    just
    obsidian
    gopass
    gopass-jsonapi
    google-chrome
    stremio
    spotify
    systemctl-tui
    macchina # system info
    lmstudio # ai model manager
    rage
    gitui
    telegram-desktop
    transmission_4-qt

    digital

    vscode-fhs # FHS variant, which allows installing extensions

    # nix tooling
    nixfmt-rfc-style
    nixd

    #kde
    kdePackages.kcalc
    catppuccin-kde
    kdePackages.kate
    kdePackages.kgpg
  ];

  home.shellAliases = {
    ls = "exa -l";
    neofetch = "macchina";
    tig = "gitui";
  };

  fonts = {
    fontconfig = {
      enable = true;
    };
  };

}
