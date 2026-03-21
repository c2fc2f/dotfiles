{
  pkgs,
  username,
  ...
}:
/*
  Kitty terminal emulator for the user.Kitty is a fast, GPU-accelerated
  terminal with advanced features like ligature support, image display, tabs,
  and extensive customization options.
*/
{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono # JetBrains Mono Nerd Font
  ];

  home-manager.users.${username} = {
    programs.kitty = {
      enable = true;
      settings = {
        font_family = "JetBrainsMono Nerd Font";
        font_size = 10.5;
        window_padding_width = 4;
        background_opacity = 0.9;

        background = "#000000";
        foreground = "#deddda";

        selection_background = "#1c1c1c";
        selection_foreground = "#c0bfbc";

        url_color = "#1a5fb4";

        wayland_titlebar_color = "system";
        macos_titlebar_color = "system";

        cursor = "#ff69ff";
        cursor_text_color = "#000000";

        active_border_color = "#1e1e1e";
        inactive_border_color = "#282828";
        bell_border_color = "#ed333b";
        visual_bell_color = "none";

        active_tab_background = "#101010";
        active_tab_foreground = "#fcfcfc";
        inactive_tab_background = "#1c1c1c";
        inactive_tab_foreground = "#b0afac";

        tab_bar_background = "none";
        tab_bar_margin_color = "none";

        color0 = "#000000";
        color1 = "#ed333b";
        color2 = "#57e389";
        color3 = "#ff7800";
        color4 = "#62a0ea";
        color5 = "#9141ac";
        color6 = "#5bc8af";
        color7 = "#deddda";
        color8 = "#9a9996";
        color9 = "#f66151";
        color10 = "#8ff0a4";
        color11 = "#ffa348";
        color12 = "#99c1f1";
        color13 = "#dc8add";
        color14 = "#93ddc2";
        color15 = "#f6f5f4";

      };
    };

    programs.zsh.shellAliases = {
      icat = "kitten icat";
      clipboard = "kitten clipboard";
    };
  };
}
