# Use this with Home Manager only
{
  pkgs,
  ...
}:
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

  # disable home-manager news
  news.display = "silent";

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
    settings = {
      user.email = "santiwilly@gmail.com";
      user.name = "Santiago Fraire Willemoes";
      init.defaultBranch = "main";
    };
    includes = [
      {
        path = "~/projects/kpn/.gitconfig";
        condition = "gitdir:~/projects/kpn";
      }
    ];
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
    pkgs.kdePackages.plasma-browser-integration
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
  programs.helix = {
    enable = true;
  };
  # nix helper, replacement for nixos and home-manager
  programs.nh = {
    enable = true;
  };
  programs.uv = {
    enable = true;
    settings = {
      python-downloads = "never";
      python-preference = "only-system";
    };
  };
  programs.librewolf = {
    enable = true;
    languagePacks = [
      "en-GB"
      "es-AR"
      "pt-PT"
      "nl"
    ];
    nativeMessagingHosts = [
      pkgs.firefoxpwa
      pkgs.kdePackages.plasma-browser-integration
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
      slint-lsp
      nodejs
      tofu-ls
      opentofu
      ruff
      typos-lsp
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
      "ruff"
      "toml"
      "sql"
      "git-firefly"
      "slint"
      "mcp-server-puppeteer"
      "opentofu"
      "typos"
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
    dig
    dust # du replacement
    btop
    bottom
    dysk

    gpg-tui

    # TUI
    systemctl-tui
    gitui # tig alternative

    # python development
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
    # stremio

    onlyoffice-desktopeditors
    # ventoy-full-gtk  # marked insecure as of now

    # nix tooling
    nixfmt-rfc-style
    nixd
    nil

    nss

    #others
    firefoxpwa
    slint-lsp

    # fonts
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
    iosevka
  ];

  home.shellAliases = {
    ls = "exa -l";
    neofetch = "macchina";
    tig = "gitui";
    cat = "bat -pp";
    du = "dust";
    htop = "btm";
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
    pinentry.package = pkgs.pinentry-qt;
    defaultCacheTtlSsh = 8 * 60 * 60; # 8 hours
    maxCacheTtlSsh = 8 * 60 * 60; # 8 hours
  };

  services.kdeconnect.enable = true;
}
