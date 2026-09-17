{ username, ... }:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    languages.rust = {
      enable = true;

      extensions = {
        crates-nvim.enable = true;
      };

      lsp.enable = true;

      treesitter.enable = true;
    };

    lsp.servers.rust-analyzer.init_options = {
      checkOnSave = true;

      cargo = {
        features = "all";
      };

      procMacro = {
        enable = true;
      };

      check = {
        command = "clippy";
        features = "all";
      };

      inlayHints = {
        lifetimeElisionHints = {
          enable = "always";
        };
      };
    };
  };
}
