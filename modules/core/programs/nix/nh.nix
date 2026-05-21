{
  nh,
  pkgs,
  username,
  lib,
  ...
}:

{
  programs.nh = {
    enable = true;

    package = nh.packages.${pkgs.stdenv.hostPlatform.system}.default;

    clean = {
      enable = false;

      dates = lib.mkDefault "daily";
    };

    flake = "/home/${username}/git/dotfiles";
  };
}
