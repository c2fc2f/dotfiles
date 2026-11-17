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

    mdsh.enable = true;

    deadnix.enable = true;
    nixfmt = {
      enable = pkgs.ghc.bootstrapAvailable;

      width = 70;
      strict = true;
    };

    yamlfmt = {
      enable = true;

      settings.formatter = {
        retain_line_breaks = true;
      };
    };
  };
}
