{ pkgs, username, ... }:

{
  fonts.packages = with pkgs; [ montserrat ];

  home-manager.users.${username} = {
    systemd.user.services.ashell = {
      Service = {
        Environment = "WGPU_BACKEND=gl";
      };
    };

    home.packages = with pkgs; [
      brightnessctl
      pamixer
    ];

    programs.ashell = {
      enable = true;

      systemd.enable = true;

      settings = {
        outputs = "All";
        position = "Top";

        enable_esc_key = true;

        region = "fr-FR";

        osd = {
          enabled = true;
          timeout = 1500;
          show_volume_percentage = true;
          show_brightness_percentage = true;
        };

        modules = {
          left = [ "SystemInfo" ];
          center = [ "WindowTitle" ];
          right = [
            [
              "Tray"
              "Privacy"
              "Tempo"
              "Settings"
            ]
          ];
        };

        system_info = {
          indicators = [
            "Cpu"
            "Memory"
            "Temperature"
          ];
        };

        tempo = {
          clock_format = "%a %d %b %T";
          weather_location = {
            City = "Rouen";
          };
        };

        settings = {
          shutdown_cmd = "shutdown now";
          suspend_cmd = "systemctl suspend";
          reboot_cmd = "systemctl reboot";
          logout_cmd = "loginctl kill-user $(whoami)";
        };

        appearance = {
          font_name = "Montserrat";
          scale_factor = 1.0;
          style = "Islands";
          opacity = 1.0;

          menu = {
            opacity = 1.0;
            backdrop = 0.3;
          };

          primary_color = "#f0f0f0";
          success_color = "#45f045";
          text_color = "#f0f0f0";

          workspace_colors = [ "#f0f0f0" ];

          danger_color = {
            base = "#f7768e";
            weak = "#e0af68";
          };

          background_color = {
            base = "#000000";
            weak = "#323232";
          };

          secondary_color = {
            base = "#0c0c0c";
          };
        };
      };
    };
  };
}
