{
  nh,
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    programs.nh = {
      enable = true;

      package = nh.packages.${pkgs.stdenv.hostPlatform.system}.default;

      clean = {
        enable = true;

        dates = "daily";
      };

      flake = "/home/${username}/git/dotfiles";
    };
  };
}
