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

        background = "#fafafa";
        foreground = "#5b6673";
        cursor = "#ff69ff";
        selection_background = "#f0ede4";
        color0 = "#000000";
        color8 = "#323232";
        color1 = "#ff0000";
        color9 = "#ff6565";
        color2 = "#86b200";
        color10 = "#b8e532";
        color3 = "#ff7f00";
        color11 = "#ffc800";
        color4 = "#41a6d9";
        color12 = "#73d7ff";
        color5 = "#ff00ff";
        color13 = "#ffa3ff";
        color6 = "#4cbe99";
        color14 = "#7ff0cb";
        color7 = "#ffffff";
        color15 = "#ffffff";
        selection_foreground = "#fafafa";
      };
    };

    programs.zsh.shellAliases = {
      icat = "kitten icat";
      clipboard = "kitten clipboard";
    };
  };
}
