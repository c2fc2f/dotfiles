{
  config,
  pkgs,
  username,
  lib,
  ...
}:
let
  inherit (config.home-manager.users.${username}.xdg) configHome;

  geminiLauncher = pkgs.makeDesktopItem {
    name = "gemini";
    desktopName = "Gemini";
    exec = "${lib.getExe pkgs.brave} --user-data-dir=${configHome}/chromium-gemini --app=https://gemini.google.com";
    icon = "${./assets/gemini.svg}";
    comment = "Launch Gemini in standalone window";
  };
in
{
  home-manager.users.${username} = {
    home.packages = [
      geminiLauncher
    ];
  };
}
