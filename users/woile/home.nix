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
  programs.gpg.publicKeys = [
    { source = ../../crypto/gpg-pubkeys.txt; trust = 5; }
  ];
  programs.starship.enable = true;
  programs.firefox.enable = true;
  programs.poetry = {
    enable = true;
    settings = {
      virtualenvs.create = true;
      virtualenvs.in-project = true;
    };
  };

  programs.zed-editor = {
    enable = true;
    # package = pkgsUnstable.zed-editor;
    # extension list:
    # https://github.com/zed-industries/extensions/tree/main/extensions
    extensions = [
      "zed-python-refactoring"
      "nix"
      "http"
      "jinja2"
      "just"
      "kdl"
      "mermaid"
      "nickel"
      "toml"
      "sql"
    ];
    userSettings = (builtins.fromJSON (builtins.readFile ../../programs/zed-editor/settings.json));
    userKeymaps = (builtins.fromJSON (builtins.readFile ../../programs/zed-editor/keymaps.json));
  };

  home.packages = [
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
    pkgs.macchina # system info
    pkgs.lmstudio # ai model manager
    pkgs.rage
    pkgs.gitui
    pkgs.telegram-desktop
    pkgs.transmission_4-qt
    pkgs.signal-desktop
    pkgs.vlc
    pkgs.digital

    pkgs.vscode-fhs # FHS variant, which allows installing extensions

    # nix tooling
    pkgs.nixfmt-rfc-style
    pkgs.nixd
    pkgs.nil

    #kde
    pkgs.kdePackages.kcalc
    pkgs.catppuccin-kde
    pkgs.kdePackages.kate
    pkgs.kdePackages.kgpg

    pkgs.onlyoffice-desktopeditors
    # fonts
    # pkgsUnstable.nerd-fonts.fira-code
    # pkgsUnstable.nerd-fonts.droid-sans-mono
    # pkgsUnstable.nerd-fonts.jetbrains-mono
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

  services.gpg-agent = {
    enable = true;
    enableBashIntegration = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
}
