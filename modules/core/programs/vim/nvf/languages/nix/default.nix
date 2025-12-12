{ username, ... }:

{

  home-manager.users.${username} = {
    programs.nvf.settings.vim.languages.nix = {
      enable = true;

      extraDiagnostics.enable = true;

      format = {
        enable = true;

        type = [
          "nixfmt"
        ];
      };

      lsp = {
        enable = true;
      };

      treesitter = {
        enable = true;
      };
    };
  };
}
