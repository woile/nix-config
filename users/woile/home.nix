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
  programs.bat = {
    enable = true;
  };
  programs.gpg.enable = true;
  programs.gpg.publicKeys = [
    {
      source = ../../crypto/gpg-pubkeys.txt;
      trust = 5;
    }
  ];
  programs.starship.enable = true;
  programs.firefox.enable = true;
  programs.firefox.nativeMessagingHosts = [
    pkgs.firefoxpwa
  ];
  programs.poetry = {
    enable = true;
    settings = {
      virtualenvs.create = true;
      virtualenvs.in-project = true;
    };
  };
  programs.wezterm = {
    enable = true;
  };

  programs.librewolf = {
    enable = true;
    languagePacks = [
      "en-GB"
      "es-AR"
      "pt-PT"
      "nl"
    ];
  };
  programs.zed-editor = {
    enable = true;
    extraPackages = with pkgs; [
      nixd
      package-version-server
      nixfmt-rfc-style
      wayland
      libxkbcommon
      libinput
    ];
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
      "git-firefly"
      "slint"
      "mcp-server-puppeteer"
    ];
    userSettings = (builtins.fromJSON (builtins.readFile ../../programs/zed-editor/settings.json));
    userKeymaps = (builtins.fromJSON (builtins.readFile ../../programs/zed-editor/keymaps.json));
  };

  home.packages = with pkgs; [
    # custom coreutils
    just # make alternative
    rage # age encryption
    macchina # neofetch alternative
    d2 # diagrams

    # TUI
    systemctl-tui
    gitui # tig alternative

    # python development
    uv # python package manager
    python312

    # security
    gopass
    gopass-jsonapi
    openssl

    # GUI
    obsidian
    telegram-desktop
    transmission_4-qt
    signal-desktop-bin
    vlc
    digital
    element-desktop
    vscode-fhs # FHS variant, which allows installing extensions
    google-chrome
    stremio
    spotify
    onlyoffice-desktopeditors
    windsurf
    code-cursor
    ventoy-full-qt

    # nix tooling
    nixfmt-rfc-style
    nixd
    nil

    nss

    #others
    firefoxpwa
  ];

  home.shellAliases = {
    ls = "exa -l";
    neofetch = "macchina";
    tig = "gitui";
    cat = "bat -pp";
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
    defaultCacheTtlSsh = 8 * 60 * 60; # 8 hours
    maxCacheTtlSsh = 8 * 60 * 60; # 8 hours
  };

}
