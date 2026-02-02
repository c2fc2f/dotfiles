{
  pkgs,
  username,
  ...
}:
/*
  mpv, a versatile and high-performance media player that supports a wide
  range of video and audio formats. It offers a minimal interface, advanced
  configuration options, and scripting support.
*/
{
  home-manager.users.${username} = {
    xdg.mimeApps = {
      defaultApplications = {
        "video/mp4" = "mpv.desktop";
      };
    };

    home.packages = [
      pkgs.mpv
    ];
  };
}
