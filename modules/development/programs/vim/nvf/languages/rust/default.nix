{ username, ... }:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    languages.rust = {
      enable = true;

      extensions = {
        crates-nvim.enable = true;
      };

      lsp = {
        enable = true;
        opts = ''
          ['rust-analyzer'] = {
            checkOnSave = true,
            procMacro = {
              enable = true,
            },
            check = {
              command = "clippy",
            },
            inlayHints = {
              lifetimeElisionHints = {
                enable = "always",
              },
            },
          }
        '';
      };

      treesitter.enable = true;
    };
  };
}
