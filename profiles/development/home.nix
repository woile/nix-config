{
  pkgs,
  ...
}:
{
  programs.zed-editor = {
    enable = true;
    extraPackages = with pkgs; [
      nixd
      package-version-server
      nixfmt
      wayland
      libxkbcommon
      libinput
      nodejs
      tofu-ls
      opentofu
      ruff
      typos-lsp
      tombi
      harper
    ];
    # package = pkgsUnstable.zed-editor;
    # extension list:
    # https://github.com/zed-industries/extensions/tree/main/extensions
    extensions = [
      "assembly"
      "zed-python-refactoring"
      "nix"
      "http"
      "jinja2"
      "just"
      "kdl"
      "mermaid"
      "nickel"
      "tombi"
      "sql"
      "git-firefly"
      "slint"
      "harper"
      "mcp-server-puppeteer"
      "opentofu"
      "typos"
      "dependi"
    ];
    userSettings = (builtins.fromJSON (builtins.readFile ../../programs/zed-editor/settings.json));
    userKeymaps = (builtins.fromJSON (builtins.readFile ../../programs/zed-editor/keymaps.json));
  };

  programs.poetry = {
    enable = false;
    settings = {
      virtualenvs.create = true;
      virtualenvs.in-project = true;
    };
  };
}
