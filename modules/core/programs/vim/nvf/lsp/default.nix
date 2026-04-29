{ username, ... }:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    lsp = {
      enable = true;

      formatOnSave = true;

      lspconfig = {
        enable = true;
      };

      inlayHints.enable = true;
    };
  };
}
