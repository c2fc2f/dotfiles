{
  config,
  pkgs,
  username,
  lib,
  ...
}:
let
  inherit (config.home-manager.users.${username}.xdg) configHome;

  chatgptLauncher = pkgs.makeDesktopItem {
    name = "chatgpt";
    desktopName = "ChatGPT";
    exec = "${lib.getExe pkgs.brave} --user-data-dir=${configHome}/chromium-chatgpt --app=https://chatgpt.com";
    icon = "${./assets/chatgpt.svg}";
    comment = "Launch ChatGPT in standalone window";
  };
in
{
  home-manager.users.${username} = {
    home.packages = [
      chatgptLauncher
    ];
  };
}
