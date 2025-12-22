{
  config,
  pkgs,
  username,
  lib,
  ...
}:
let
  inherit (config.home-manager.users.${username}.xdg) configHome;

  claudeLauncher = pkgs.makeDesktopItem {
    name = "claude.ai";
    desktopName = "Claude.AI";
    exec = "${lib.getExe pkgs.brave} --user-data-dir=${configHome}/chromium-claude --app=https://claude.ai";
    icon = "${./assets/claude.svg}";
    comment = "Launch Claude.AI in standalone window";
  };
in
{
  home-manager.users.${username} = {
    home.packages = [
      claudeLauncher
    ];
  };
}
