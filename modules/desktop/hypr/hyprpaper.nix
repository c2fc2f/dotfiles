{ username, ... }:
/*
  Hyprpaper, a lightweight wallpaper daemon for Hyprland. It is designed to
  efficiently set and manage wallpapers on Wayland setups using Hyprland, with
  support for multiple monitors and per-display images.
*/
{
  home-manager.users.${username} = {
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = [
          "${./assets/background.jpg}"
        ];
        wallpaper = [
          ",${./assets/background.jpg}"
        ];
        splash = false;
        ipc = "off";
      };
    };
  };
}
