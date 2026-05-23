{
  lib,
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    languages.nix = {
      enable = true;

      extraDiagnostics.enable = true;

      format.enable = false;

      lsp = {
        enable = true;
      };

      treesitter = {
        enable = true;
      };
    };

    formatter.conform-nvim = {
      enable = true;
      setupOpts = {
        format_on_save = {
          timeout_ms = 1000000;
        };

        formatters_by_ft = {
          nix = [ "nix-fmt" ];
        };

        formatters = {
          nix-fmt = {
            command = lib.getExe pkgs.nix;
            args = [
              "fmt"
              "$FILENAME"
            ];
            stdin = false;
          };
        };
      };
    };
  };
}
