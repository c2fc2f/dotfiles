{ username, ... }:
/*
  Hypridle service, a lightweight Wayland-compatible idle daemon designed to
  work with Hyprland. Hypridle monitors user activity (keyboard, mouse) and
  triggers actions after defined periods of inactivity.
*/
{
  home-manager.users.${username} = {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = 3600;
            on-timeout = "loginctl lock-session";
            on-resume = ''notify-send "Welcome back!"'';
          }
          {
            timeout = 3630;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
