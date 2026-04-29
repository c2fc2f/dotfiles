{ pkgs, username, ... }:
/*
  Hyprlock, the official screen locker for Hyprland. Hyprlock is designed to
  integrate seamlessly with Hyprland, supporting modern aesthetics,
  animations, and Wayland-native security.
*/
{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono # JetBrains Mono Nerd Font
  ];

  home-manager.users.${username} = {
    programs.hyprlock = {
      enable = true;
      settings = {
        background = {
          path = "${../../assets/background.jpg}";
          blur_passes = "2";
          contrast = "1";
          brightness = "0.7";
          vibrancy = "0.2";
          vibrancy_darkness = "0.2";
        };
        general = {
          no_fade_in = true;
          no_fade_out = true;
          hide_cursor = false;
          grace = 0;
          disable_loading_bar = true;
        };
        input-field = {
          size = "250, 60";
          outline_thickness = 2;
          dots_size = "0.2";
          dots_spacing = "0.35";
          dots_center = true;
          outer_color = "rgba(205, 214, 244, 0.2)";
          inner_color = "rgba(0, 0, 0, 0.2)";
          font_color = "$foreground";
          fade_on_empty = false;
          rounding = "-1";
          check_color = "rgb(204, 136, 34)";
          placeholder_text = ''
            <i><span foreground="##cdd6f4">Input Password...</span></i>
          '';
          hide_input = false;
          position = "0, -200";
          halign = "center";
          valign = "center";
        };
        label = [
          {
            text = ''cmd[update:1000] echo "$(date +"%A, %B %d")"'';
            color = "rgba(242, 243, 244, 0.75)";
            font_size = 22;
            font_family = "JetBrainsMono Nerd Font";
            position = "0, 300";
            halign = "center";
            valign = "center";
          }
          {
            text = ''cmd[update:1000] echo "$(date +"%-I:%M")"'';
            color = "rgba(242, 243, 244, 0.75)";
            font_size = 95;
            font_family = "JetBrainsMono Nerd Font";
            font_weight = "800";
            position = "0, 200";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
