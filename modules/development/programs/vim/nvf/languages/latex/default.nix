{
  pkgs,
  lib,
  username,
  ...
}:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    lazy.plugins.vimtex = {
      enabled = true;

      package = pkgs.vimPlugins.vimtex;

      lazy = true;
      ft = "tex";
    };

    globals = {
      vimtex_view_method = "zathura";
      vimtex_view_zathura_check_libsynctex = false;
      vimtex_compiler_method = "latexmk";
      vimtex_compiler_clean_paths = [
        "_minted*"
      ];
      vimtex_compiler_latexmk_engines = {
        "_" = "-lualatex";
      };
      vimtex_compiler_latexmk = {
        options = [
          "-verbose"
          "-synctex=1"
          "-interaction=nonstopmode"
          "-file-line-error"
          "-shell-escape"
        ];
      };
    };

    lsp = {
      servers = {
        texlab = {
          enable = true;
          cmd = [
            "${lib.getExe pkgs.texlab}"
          ];
          filetypes = [
            "tex"
          ];

          settings = {
            texlab = {
              chktex = {
                onEdit = true;
                onOpenAndSave = true;
              };

              latexFormatter = "tex-fmt";
              bibtexFormatter = "tex-fmt";
            };
          };
        };
      };
    };
  };
}
