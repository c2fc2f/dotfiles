{
  username,
  pkgs,
  lib,
  ...
}:

{
  home-manager.users.${username} = {
    programs.nvf.settings.vim = {
      languages.clang = {
        enable = true;
        cHeader = true;
      };

      formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft = {
            c = lib.mkOverride 5 [ "uncrustify" ];
          };
          formatters = {
            uncrustify = {
              command = lib.getExe pkgs.uncrustify;
              args = [
                "-c"
                "${./uncrustify078_c.cfg}"
                "-l"
                "C"
                "-q"
                "--no-backup"
              ];
            };
          };
        };
      };

      keymaps = [
        {
          key = "<F8>";
          mode = "n";
          action = "<cmd>!gcc -Wall -Wconversion -Werror -Wextra -Wpedantic -Wwrite-strings -std=c2x %<CR>";
          desc = "Compile using gcc";
        }
        {
          key = "<F9>";
          mode = "n";
          action = "<cmd>make<CR>";
          desc = "Compile using make";
        }
        {
          key = "<F10>";
          mode = "n";
          action = "<cmd>copen<CR>";
          desc = "Open error panel";
        }
      ];

      luaConfigRC.geany_make_setup = lib.mkAfter ''
        vim.opt.makeprg = "make"

        vim.api.nvim_create_autocmd("QuickFixCmdPost", {
          pattern = "[^l]*",
          command = "cwindow"
        })
      '';
    };

    home.file.".config/clangd/config.yaml".text = ''
      CompileFlags:
        Add: 
          - "-std=c2y"
          - "-Wall"
          - "-Wconversion"
          - "-Werror"
          - "-Wextra"
          - "-Wpedantic"
          - "-Wwrite-strings"
    '';
  };
}
