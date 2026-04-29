{ username, ... }:

{
  home-manager.users.${username} = {
    qt = {
      enable = true;

      platformTheme = {
        name = "adwaita";
      };
      style = {
        name = "adwaita-dark";
      };
    };
  };
}
