{
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    services.dunst = {
      enable = true;

      settings = {
        global = {
          width = "(100, 600)";
          height = "(0, 300)";
          origin = "top-right";
          offset = "(5, 15)";
          scale = 0;
          notification_limit = 10;

          monitor = 0;
          follow = "mouse";

          progress_bar = true;
          progress_bar_height = 14;
          progress_bar_frame_width = 0;
          progress_bar_min_width = 100;
          progress_bar_max_width = 300;
          progress_bar_corner_radius = 50;
          progress_bar_corners = "bottom-left, top-right";

          icon_corner_radius = 0;
          icon_corners = "all";
          indicate_hidden = "yes";
          transparency = 0;
          separator_height = 6;
          padding = 10;
          horizontal_padding = 8;
          text_icon_padding = 12;

          frame_width = 1;
          frame_color = "#a0a0a0";
          gap_size = 6;
          separator_color = "frame";
          sort = "yes";
          font = "Fira Mono 12";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>\\n%b";
          vertical_alignment = "center";
          show_age_threshold = -1;
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";

          enable_recursive_icon_lookup = true;
          icon_theme = "Adwaita, Papirus, Papirus-Dark";
          icon_position = "right";
          min_icon_size = 32;
          max_icon_size = 128;

          sticky_history = "yes";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          corner_radius = 10;
          corners = "bottom, top-left";

          ignore_dbusclose = false;
          force_xwayland = false;
          force_xinerama = false;

          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
        };

        experimental = {
          per_monitor_dpi = false;
        };

        urgency_low = {
          background = "#222222";
          foreground = "#ffffff";
          highlight = "#722ae6, #e4b5cb";
          timeout = 20;
        };

        urgency_normal = {
          background = "#222222";
          foreground = "#ffffff";
          frame_color = "#5e5086";
          highlight = "#722ae6, #e4b5cb";
          timeout = 20;
          override_pause_level = 30;
          default_icon = "dialog-information";
        };

        urgency_critical = {
          background = "#222222";
          foreground = "#ffffff";
          frame_color = "#d54e53";
          highlight = "#d54e53, #f0f0f0";
          timeout = 0;
          override_pause_level = 60;
          default_icon = "dialog-warning";
        };
      };

      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
    };
  };
}
