{
  username,
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (config.home-manager.users.${username}.xdg) configHome;

  webapp = [
    {
      name = "Youtube";
      url = "https://www.youtube.com";
      extraFlags = [
        "--incognito"
      ];
    }
    {
      name = "Figma";
      url = "https://figma.com";
    }
    {
      name = "Gemini";
      url = "https://gemini.google.com";
    }
    {
      name = "Claude";
      url = "https://claude.ai";
    }
    {
      name = "ChatGPT";
      url = "https://chatgpt.com";
    }
  ];

  makeWrapper =
    app:
    pkgs.makeDesktopItem {
      name = lib.toLower app.name;
      desktopName = app.name;
      exec =
        "${lib.getExe pkgs.brave} --user-data-dir=${configHome}/chromium-${lib.toLower app.name} --app=${app.url} "
        + (lib.concatStringsSep " " (app.extraFlags or [ ]));
      icon = "${./assets/${lib.toLower app.name}.svg}";
      comment = "Launch ${app.name} in standalone window";
    };
in
{
  home-manager.users.${username} = {
    home.packages = map makeWrapper webapp;
  };
}
