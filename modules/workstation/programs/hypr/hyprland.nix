{
  pkgs,
  hyprland,
  username,
  ...
}:
/*
  Hyprland, a dynamic tiling Wayland compositor that supports modern features
  like animations, gestures, and advanced window management. It's known for
  its performance, configurability, and support for NVIDIA GPUs and HDR.
*/
{
  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      brightnessctl
      pamixer
      playerctl
    ];

    home.file = {
      ".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;

      settings = {
        # Environement Variables
        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];

        # Monitors
        monitor = [
          ",preferred,auto,1"
        ];

        # Programs
        "$terminal" = "kitty";
        "$fileManager" = "yazi";
        "$menu" = "rofi -show drun";

        # Look and feel

        general = {
          gaps_in = 2.5;
          gaps_out = 2.5;

          border_size = 2;

          "col.active_border" = "rgba(363656ee)";
          "col.inactive_border" = "rgba(595959aa)";

          resize_on_border = false;

          allow_tearing = false;

          layout = "dwindle";
        };

        decoration = {
          rounding = 0;

          active_opacity = "1.0";
          inactive_opacity = "1.0";

          shadow = {
            enabled = false;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };

          blur = {
            enabled = true;
            size = 5;
            passes = 2;

            vibrancy = "0.1696";
          };
        };

        animations = {
          enabled = true;

          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        master = {
          new_status = "master";
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };

        cursor = {
          no_hardware_cursors = true;
        };

        # Inputs

        input = {
          kb_layout = "fr";
          follow_mouse = 1;
          sensitivity = 0;

          touchpad = {
            natural_scroll = false;
          };

          numlock_by_default = true;
        };

        device = [
          {
            name = "epic-mouse-v1";
            sensitivity = "-0.5";
          }
        ];

        windowrule = "match:class .*, suppress_event maximize fullscreen";

        "$mod" = "SUPER";

        bind = [
          # Screenshot
          ", Print, exec, focal image --area selection"
          "$mod, Print, exec, focal video --rofi --audio"

          # Special keys
          ", xf86monbrightnessup, exec, brightnessctl set 10%+"
          ", xf86monbrightnessdown, exec, brightnessctl set 10%-"
          ", xf86audioraisevolume, exec, pamixer -i 5"
          ", xf86audiolowervolume, exec, pamixer -d 5"
          ", xf86audiomute, exec, pamixer -t"

          ", xf86audioplay, exec, playerctl play-pause"
          ", xf86audiopause, exec, playerctl play-pause"
          ", xf86audionext, exec, playerctl next"
          ", xf86audioprev, exec, playerctl previous"

          # Default bind
          "$mod, Return, exec, $terminal"
          "$mod SHIFT, Q, killactive,"
          "$mod, M, exit,"
          "$mod, E, exec, $fileManager"
          "$mod, Space, togglefloating"
          "$mod, D, exec, pkill -x rofi || $menu"
          "$mod, P, pseudo,"

          # Lock the session
          "$mod, L, exec, hyprlock"

          # Move focus with mod + arrow keys
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Move window with mod + shift + arrow keys
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"

          # Resize window with mod + alt + arrow keys
          "$mod ALT, left, resizeactive, -10 0"
          "$mod ALT, right, resizeactive, 10 0"
          "$mod ALT, up, resizeactive, 0 -10"
          "$mod ALT, down, resizeactive, 0 10"

          # Toggle fullscreen
          "$mod, F, fullscreen"

          # Switch workspaces with mod + [0-9]
          "$mod, ampersand, workspace, 1"
          "$mod, eacute, workspace, 2"
          "$mod, quotedbl, workspace, 3"
          "$mod, apostrophe, workspace, 4"
          "$mod, parenleft, workspace, 5"
          "$mod, minus, workspace, 6"
          "$mod, egrave, workspace, 7"
          "$mod, underscore, workspace, 8"
          "$mod, ccedilla, workspace, 9"
          "$mod, agrave, workspace, 10"

          # Move active window to a workspace with mod + SHIFT + [0-9]
          "$mod SHIFT, ampersand, movetoworkspace, 1"
          "$mod SHIFT, eacute, movetoworkspace, 2"
          "$mod SHIFT, quotedbl, movetoworkspace, 3"
          "$mod SHIFT, apostrophe, movetoworkspace, 4"
          "$mod SHIFT, parenleft, movetoworkspace, 5"
          "$mod SHIFT, minus, movetoworkspace, 6"
          "$mod SHIFT, egrave, movetoworkspace, 7"
          "$mod SHIFT, underscore, movetoworkspace, 8"
          "$mod SHIFT, ccedilla, movetoworkspace, 9"
          "$mod SHIFT, agrave, movetoworkspace, 10"

          # Special workspace (scratchpad)
          "$mod, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"
        ];

        bindm = [
          # Move/resize windows with mod + LMB/RMB and dragging
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
