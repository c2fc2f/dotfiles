{
  config,
  pkgs,
  username,
  lib,
  ...
}:
let
  inherit (config.home-manager.users.${username}.xdg) configHome;

  youtubeLauncher = pkgs.makeDesktopItem {
    name = "youtube";
    desktopName = "Youtube";
    exec = "${lib.getExe pkgs.brave} --user-data-dir=${configHome}/chromium-youtube --app=https://www.youtube.com --incognito";
    icon = "${./assets/youtube.svg}";
    categories = [
      "Video"
      "AudioVideo"
    ];
    comment = "Launch Youtube in standalone window";
  };
in
{
  home-manager.users.${username} = {
    home.packages = [
      youtubeLauncher
    ];
  };
}
