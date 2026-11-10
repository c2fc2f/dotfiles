{ pkgs, username, ... }:

{
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  home-manager.users.${username} = {
    programs.swaylock = {
      enable = true;

      settings = {
        image = "${../../assets/background.jpg}";

        indicator = true;
        indicator-radius = 100;
        indicator-thickness = 10;

        ring-color = "cdd6f4";
        key-hl-color = "cc8822";
        line-color = "00000000";
        inside-color = "00000033";
        separator-color = "00000000";

        text-color = "cdd6f4";
        font = "JetBrainsMono Nerd Font";
        font-size = 22;

        ignore-empty-password = true;
      };
    };
  };

  security.pam.services.swaylock = { };
}
