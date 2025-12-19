{ pkgs, username, ... }:

{
  fonts.packages = with pkgs; [
    montserrat
  ];

  home-manager.users.${username} = {
    programs.ashell = {
      enable = true;

      systemd.enable = true;

      settings = {
        outputs = "All";
        position = "Top";

        enable_esc_key = true;

        modules = {
          left = [
            "SystemInfo"
            [
              "Workspaces"
            ]
          ];
          center = [
            "WindowTitle"
          ];
          right = [
            [
              "Tray"
              "Privacy"
              "Clock"
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

        clock = {
          format = "%a %d %b %T";
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

          workspace_colors = [
            "#f0f0f0"
          ];

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
