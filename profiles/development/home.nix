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
      ts_query_ls
      color-lsp
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
      "mcp-server-puppeteer"
      "opentofu"
      "typos"
      "dependi"
      "tree-sitter-query"
      "log"
      "color-highlight"
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
