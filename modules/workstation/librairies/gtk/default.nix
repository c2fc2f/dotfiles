{ pkgs, username, ... }:
/*
  GTK configuration for the user and sets the icon theme.
   - `enable = true` activates GTK settings management through Home Manager.
   - Sets the icon theme to "Adwaita", using the corresponding package,
     for consistent look and feel across GTK applications.
*/
{
  home-manager.users.${username} = {
    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
    };
  };
}
