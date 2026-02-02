{
  pkgs,
  username,
  ...
}:
/*
  wl-mirror, a Wayland utility for mirroring a specific output or region of
  the screen. It is useful for screen sharing, presentations, and recording
  setups in Wayland-based environments.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.wl-mirror
    ];
  };
}
