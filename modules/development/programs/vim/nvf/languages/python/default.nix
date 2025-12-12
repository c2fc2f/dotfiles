{ username, ... }:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    languages.python = {
      enable = true;

      format = {
        enable = true;

        type = [
          "ruff"
        ];
      };

      lsp = {
        enable = true;

        servers = [
          "pyright"
        ];
      };

      treesitter = {
        enable = true;
      };
    };
  };
}
