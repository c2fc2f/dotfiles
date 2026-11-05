{
  username,
  pkgs,
  lib,
  config,
  rootDomain,
  ...
}:
let
  inherit (config.home-manager.users.${username}.xdg) configHome;

  webapp = [
    {
      name = "Youtube";
      url = "https://www.youtube.com";
      extraFlags = [ "--incognito" ];
      extensions = with pkgs.custom.chromium; [
        ublock-origin
        sponsor-block
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
    {
      name = "SAGAI";
      url = "https://chat.${rootDomain}";
    }
  ];

  makeWrapper =
    app:
    pkgs.makeDesktopItem {
      name = lib.toLower app.name;
      desktopName = app.name;
      exec =
        (lib.getExe pkgs.unstable.ungoogled-chromium)
        + " "
        + (lib.concatStringsSep " " (
          [
            "--user-data-dir=${configHome}/chromium-${lib.toLower app.name}"
            "--app=${app.url}"

            "--process-per-site"
            "--renderer-process-limit=1"
            "--no-pings"
            "--disable-cache"
            "--disk-cache-size=1"
            "--media-cache-size=1"
            "--disk-cache-dir=/dev/null"
            "--disable-application-cache"
            "--disable-gpu-shader-disk-cache"
          ]
          ++ (lib.optional (
            app ? extensions && builtins.length app.extensions > 0
          ) "--load-extension=${lib.concatStringsSep "," app.extensions}")
          ++ (app.extraFlags or [ ])
        ));
      icon = "${./assets/${lib.toLower app.name}.svg}";
      comment = "Launch ${app.name} in standalone window";
    };
in
{
  nixpkgs.overlays = [ (import ./_extensions) ];

  home-manager.users.${username} = {
    home.packages = map makeWrapper webapp;
  };
}
