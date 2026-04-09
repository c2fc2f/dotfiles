{
  username,
  pkgs,
  ...
}:

{
  home-manager.users.${username} = {
    home.pointerCursor = {
      enable = true;

      name = "Vanilla-DMZ";
      size = 24;
      package = pkgs.vanilla-dmz;
    };
  };
}
