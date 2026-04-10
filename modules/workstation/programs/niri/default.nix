{
  pkgs,
  lib,
  config,
  nix-wrapper,
  focal,
  niri,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;

  toggleMagic = pkgs.writeShellApplication {
    name = "toggle-magic";
    runtimeInputs = with pkgs; [
      jq
    ];
    text = ''
      CURRENT_WS=$(niri msg --json workspaces | jq -r '.[] | select(.is_focused == true) | .name')
      if [ "$CURRENT_WS" == "magic" ]; then
        niri msg action focus-workspace-previous
      else
        niri msg action focus-workspace "magic"
      fi
    '';
  };
in
{
  programs.niri = {
    enable = true;
    package = nix-wrapper.wrappers.niri.wrap {
      inherit pkgs;

      package = niri.packages.${system}.default;

      settings = {
        prefer-no-csd = null;

        input = {
          keyboard = {
            xkb.layout = "fr";
            numlock = true;
          };
        };

        binds = {
          "Mod+Return".spawn = lib.getExe pkgs.kitty;

          "Mod+Shift+Q".close-window = { };
          "Mod+X".maximize-column = { };
          "Mod+F".fullscreen-window = { };
          "Mod+Shift+F".toggle-windowed-fullscreen = { };
          "Mod+Space".toggle-window-floating = { };
          "Mod+C".center-column = { };

          "Mod+Left".focus-column-left = { };
          "Mod+Right".focus-column-right = { };
          "Mod+Up".focus-window-up = { };
          "Mod+Down".focus-window-down = { };

          "Mod+Shift+Left".move-column-left = { };
          "Mod+Shift+Right".move-column-right = { };
          "Mod+Shift+Up".move-window-up = { };
          "Mod+Shift+Down".move-window-down = { };

          "Mod+ampersand".focus-workspace = "_w1";
          "Mod+eacute".focus-workspace = "_w2";
          "Mod+quotedbl".focus-workspace = "_w3";
          "Mod+apostrophe".focus-workspace = "_w4";
          "Mod+parenleft".focus-workspace = "_w5";
          "Mod+minus".focus-workspace = "_w6";
          "Mod+egrave".focus-workspace = "_w7";
          "Mod+underscore".focus-workspace = "_w8";
          "Mod+ccedilla".focus-workspace = "entertainment";
          "Mod+agrave".focus-workspace = "chat";
          "Mod+S".spawn = lib.getExe toggleMagic;

          "Mod+Shift+ampersand".move-column-to-workspace = "_w1";
          "Mod+Shift+eacute".move-column-to-workspace = "_w2";
          "Mod+Shift+quotedbl".move-column-to-workspace = "_w3";
          "Mod+Shift+apostrophe".move-column-to-workspace = "_w4";
          "Mod+Shift+parenleft".move-column-to-workspace = "_w5";
          "Mod+Shift+minus".move-column-to-workspace = "_w6";
          "Mod+Shift+egrave".move-column-to-workspace = "_w7";
          "Mod+Shift+underscore".move-column-to-workspace = "_w8";
          "Mod+Shift+ccedilla".move-column-to-workspace = "entertainment";
          "Mod+Shift+agrave".move-column-to-workspace = "chat";
          "Mod+Shift+S".move-column-to-workspace = "magic";

          "Print".spawn = [
            (lib.getExe focal.packages.${system}.default)
            "image"
            "--area"
            "selection"
          ];

          # Special keys
          "xf86monbrightnessup".spawn = [
            (lib.getExe pkgs.brightnessctl)
            "set"
            "10%+"
          ];
          "xf86monbrightnessdown".spawn = [
            (lib.getExe pkgs.brightnessctl)
            "set"
            "10%-"
          ];
          "xf86audioraisevolume".spawn = [
            (lib.getExe pkgs.pamixer)
            "-i"
            "5"
          ];
          "xf86audiolowervolume".spawn = [
            (lib.getExe pkgs.pamixer)
            "-d"
            "5"
          ];
          "xf86audiomute".spawn = [
            (lib.getExe pkgs.pamixer)
            "-t"
          ];

          "xf86audioplay".spawn = [
            (lib.getExe pkgs.playerctl)
            "play-pause"
          ];
          "xf86audiopause".spawn = [
            (lib.getExe pkgs.playerctl)
            "play-pause"
          ];
          "xf86audionext".spawn = [
            (lib.getExe pkgs.playerctl)
            "next"
          ];
          "xf86audioprev".spawn = [
            (lib.getExe pkgs.playerctl)
            "previous"
          ];

          "Mod+d".spawn = [
            "rofi"
            "-show"
            "drun"
          ];

          "Mod+L".spawn = lib.getExe pkgs.hyprlock;
        };

        workspaces = {
          "_w1" = { };
          "_w2" = { };
          "_w3" = { };
          "_w4" = { };
          "_w5" = { };
          "_w6" = { };
          "_w7" = { };
          "_w8" = { };

          "entertainment" = { };
          "chat" = { };
          "magic" = { };
        };

        window-rules = [
          {
            matches = [
              {
                app-id = "vesktop";
              }
            ];
            open-on-workspace = "chat";
            open-maximized = true;
          }
          {
            matches = [
              {
                app-id = "brave-www.youtube.com__-Default";
              }
            ];
            open-on-workspace = "entertainment";
            open-maximized = true;
          }
        ];

        animations = {
          workspace-switch = {
            off = { };
          };
        };

        layout = {
          gaps = 2.5;

          focus-ring = {
            width = 2;
            active-color = "#ff69ff";
            inactive-color = "#595959";
          };
        };
      };
    };
  };

  # restart niri with new settings on rebuild
  system.userActivationScripts = {
    niri-reload-config = {
      text = lib.getExe (
        pkgs.writeShellApplication {
          name = "niri-reload-config";
          runtimeInputs = [
            config.programs.niri.package
            pkgs.procps
          ];
          text =
            let
              inherit (config.programs.niri.package.configuration.constructFiles.generatedConfig) outPath;
            in
            ''
              if pgrep -x "niri" > /dev/null; then
                niri msg action load-config-file --path "${outPath}"
              fi
            '';
        }
      );
    };
  };
}
