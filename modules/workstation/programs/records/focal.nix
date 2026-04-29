{
  pkgs,
  focal,
  username,
  ...
}:
/*
  Focal, a screenshot and screen recording utility designed for Wayland
  compositors like Hyprland and Sway. It provides a Rofi interface to take
  screenshots or videos of the screen, window, or selected area, with support
  for delayed captures and clipboard integration.
*/
{
  nix.settings = {
    substituters = [ "https://focal.cachix.org" ];
    trusted-public-keys = [
      "focal.cachix.org-1:/YkOWkXNH2uK7TnskrVMvda8LyCe4iIbMM1sZN2AOXY="
    ];
  };

  home-manager.users.${username} = {
    home.packages = [
      focal.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
