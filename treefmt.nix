{ pkgs, ... }:

{
  projectRootFile = "flake.nix";

  settings.verbose = 1;

  programs = {
    keep-sorted.enable = true;

    rustfmt.enable = true;

    shellcheck = {
      enable = pkgs.ghc.bootstrapAvailable;

      external-sources = true;
      extra-checks = [ "all" ];
      severity = "style";
    };
    shfmt = {
      enable = true;

      simplify = true;
      indent_size = 2;
    };

    mdformat = {
      enable = true;

      plugins = ps: [ ps.mdformat-gfm ];

      settings = {
        wrap = 78;
      };
    };
    mdsh.enable = true;

    deadnix.enable = true;
    nixfmt = {
      enable = pkgs.ghc.bootstrapAvailable;

      width = 70;
      strict = true;
    };

    taplo = {
      enable = true;

      settings = {
        formatting = {
          compact_arrays = false;
          array_auto_collapse = false;
          array_auto_expand = true;
          array_trailing_comma = true;
        };
      };
    };
    yamlfmt = {
      enable = true;

      settings.formatter = {
        retain_line_breaks = true;
      };
    };
  };
}
