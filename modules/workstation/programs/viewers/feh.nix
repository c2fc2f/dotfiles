{
  pkgs,
  username,
  ...
}:
/*
  feh, a fast and lightweight image viewer for the terminal and X11. Commonly
  used to view images or set desktop wallpapers from scripts or tiling window
  managers.
*/
{
  home-manager.users.${username} = {
    xdg.mimeApps = {
      defaultApplications = {
        "image/png" = "feh.desktop";
      };
    };

    home.packages = [
      pkgs.feh
    ];
  };
}
