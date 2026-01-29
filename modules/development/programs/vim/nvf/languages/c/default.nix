{
  username,
  pkgs,
  lib,
  ...
}:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    languages.clang = {
      enable = true;

      cHeader = true;
    };

    lsp.servers.clangd.cmd = lib.mkForce [
      "${pkgs.clang-tools}/bin/clangd"
      "--fallback-style=none"
    ];

    formatter.conform-nvim = {
      enable = true;
      setupOpts = {
        formatters_by_ft = {
          c = [ "uncrustify" ];
          cpp = [ "uncrustify" ];
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
  };
}
