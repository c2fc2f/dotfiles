{ username, config, ... }:
/*
  Enables XDG user directories and sets the path for the Pictures directory.
  - `enable = true` allows Home Manager to manage standard XDG user folders
  (like Documents, Downloads, etc.).
  - `picture` sets the path for the XDG_PICTURES_DIR environment variable,
     which is used by many desktop applications to locate the user's picture
     directory.
*/
{
  home-manager.users.${username}.xdg.userDirs = {
    enable = true;
    pictures = "${config.users.users.${username}.home}/Pictures";
  };
}
