{
  pkgs,
  lib,
  config,
  username,
  ...
}:
/*
  Rofi, a powerful and highly customizable application launcher, window
  switcher, SSH launcher, and more. Rofi is widely used in tiling window
  manager setups due to its speed, flexibility, and keyboard-driven workflow.
*/
{
  imports = [
    # keep-sorted start
    ./bluetooth.nix
    ./networkmanager.nix
    # keep-sorted end
  ];

  home-manager.users.${username} = {
    home.file.".config/networkmanager-dmenu/config.ini" = {
      text = ''
        [dmenu]
        dmenu_command = ${lib.getExe pkgs.rofi} -show drun -password
        active_chars = ✅
        compact = True
        wifi_chars = ▂▄▆█
      '';
    };

    programs.rofi = {
      enable = true;

      extraConfig = {
        modi = "drun,run,filebrowser";
        case-sensitive = false;
        cycle = true;
        filter = "";
        scroll-method = 0;
        normalize-match = true;
        show-icons = true;
        icon-theme = "Papirus";
        steal-focus = false;

        matching = "normal";
        tokenize = true;

        ssh-client = "ssh";
        ssh-command = "{terminal} -e {ssh-client} {host} [-p {port}]";
        parse-hosts = true;
        parse-known-hosts = true;

        drun-categories = "";
        drun-match-fields = "name,generic,exec,categories,keywords";
        drun-display-format = "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
        drun-show-actions = false;
        drun-url-launcher = "xdg-open";
        drun-use-desktop-cache = false;
        drun-reload-desktop-cache = false;

        run-command = "{cmd}";
        run-list-command = "";
        run-shell-command = "{terminal} -e {cmd}";

        window-match-fields = "title,class,role,name,desktop";
        window-command = "wmctrl -i -R {window}";
        window-format = "{w} - {c} - {t:0}";
        window-thumbnail = false;

        disable-history = false;
        sorting-method = "normal";
        max-history-size = 25;

        display-window = "Windows";
        display-windowcd = "Window CD";
        display-run = "Run";
        display-ssh = "SSH";
        display-drun = "Apps";
        display-combi = "Combi";
        display-keys = "Keys";
        display-filebrowser = "Files";

        terminal = "rofi-sensible-terminal";
        font = "Mono 12";
        sort = false;
        threads = 0;
        click-to-exit = true;
      };
      theme =
        let
          inherit (config.home-manager.users.${username}.lib.formats.rasi) mkLiteral;
        in
        {
          "*" = {
            font = "JetBrains Mono Nerd Font 10";
            background = mkLiteral "#101010";
            background-alt = mkLiteral "#252525";
            foreground = mkLiteral "#FFFFFF";
            selected = mkLiteral "#505050";
            active = mkLiteral "#909090";
            urgent = mkLiteral "#707070";
          };

          window = {
            transparency = "real";
            location = mkLiteral "center";
            anchor = mkLiteral "center";
            fullscreen = false;
            width = mkLiteral "1000px";
            x-offset = mkLiteral "0px";
            y-offset = mkLiteral "0px";

            enabled = true;
            border-radius = mkLiteral "15px";
            cursor = "default";
            background-color = mkLiteral "@background";
          };

          mainbox = {
            enabled = true;
            spacing = mkLiteral "0px";
            background-color = mkLiteral "transparent";
            orientation = mkLiteral "horizontal";
            children = [
              "imagebox"
              "listbox"
            ];
          };

          imagebox = {
            padding = mkLiteral "20px";
            background-color = mkLiteral "transparent";
            background-image = mkLiteral ''url("${builtins.toString ./assets/rofi.jpg}", height)'';
            orientation = mkLiteral "vertical";
            children = [
              "inputbar"
              "dummy"
              "mode-switcher"
            ];
          };

          listbox = {
            spacing = mkLiteral "20px";
            padding = mkLiteral "20px";
            background-color = mkLiteral "transparent";
            orientation = mkLiteral "vertical";
            children = [
              "message"
              "listview"
            ];
          };

          dummy = {
            background-color = mkLiteral "transparent";
          };

          inputbar = {
            enabled = true;
            spacing = mkLiteral "10px";
            padding = mkLiteral "15px";
            border-radius = mkLiteral "10px";
            background-color = mkLiteral "@background-alt";
            text-color = mkLiteral "@foreground";
            children = [
              "textbox-prompt-colon"
              "entry"
            ];
          };
          textbox-prompt-colon = {
            enabled = true;
            expand = false;
            str = "";
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "inherit";
          };
          entry = {
            enabled = true;
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "inherit";
            cursor = mkLiteral "text";
            placeholder = "Search";
            placeholder-color = mkLiteral "inherit";
          };

          mode-switcher = {
            enabled = true;
            spacing = mkLiteral "20px";
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "@foreground";
          };
          button = {
            padding = mkLiteral "15px";
            border-radius = mkLiteral "10px";
            background-color = mkLiteral "@background-alt";
            text-color = mkLiteral "inherit";
            cursor = mkLiteral "pointer";
          };
          "button selected" = {
            background-color = mkLiteral "@selected";
            text-color = mkLiteral "@foreground";
          };

          listview = {
            enabled = true;
            columns = 1;
            lines = 8;
            cycle = true;
            dynamic = true;
            scrollbar = false;
            layout = mkLiteral "vertical";
            reverse = false;
            fixed-height = true;
            fixed-columns = true;

            spacing = mkLiteral "10px";
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "@foreground";
            cursor = "default";
          };

          element = {
            enabled = true;
            spacing = mkLiteral "15px";
            padding = mkLiteral "8px";
            border-radius = mkLiteral "10px";
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "@foreground";
            cursor = mkLiteral "pointer";
          };
          "element normal.normal" = {
            background-color = mkLiteral "inherit";
            text-color = mkLiteral "inherit";
          };
          "element normal.urgent" = {
            background-color = mkLiteral "@urgent";
            text-color = mkLiteral "@foreground";
          };
          "element normal.active" = {
            background-color = mkLiteral "@active";
            text-color = mkLiteral "@foreground";
          };
          "element selected.normal" = {
            background-color = mkLiteral "@selected";
            text-color = mkLiteral "@foreground";
          };
          "element selected.urgent" = {
            background-color = mkLiteral "@urgent";
            text-color = mkLiteral "@foreground";
          };
          "element selected.active" = {
            background-color = mkLiteral "@urgent";
            text-color = mkLiteral "@foreground";
          };
          element-icon = {
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "inherit";
            size = mkLiteral "32px";
            cursor = mkLiteral "inherit";
          };
          element-text = {
            background-color = mkLiteral "transparent";
            text-color = mkLiteral "inherit";
            cursor = mkLiteral "inherit";
            vertical-align = mkLiteral "0.5";
            horizontal-align = mkLiteral "0.0";
          };

          message = {
            background-color = mkLiteral "transparent";
          };
          textbox = {
            padding = mkLiteral "15px";
            border-radius = mkLiteral "10px";
            background-color = mkLiteral "@background-alt";
            text-color = mkLiteral "@foreground";
            vertical-align = mkLiteral "0.5";
            horizontal-align = mkLiteral "0.0";
          };
          error-message = {
            padding = mkLiteral "15px";
            border-radius = mkLiteral "20px";
            background-color = mkLiteral "@background";
            text-color = mkLiteral "@foreground";
          };
        };
    };
  };
}
