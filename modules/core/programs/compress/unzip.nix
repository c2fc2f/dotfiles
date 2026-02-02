{
  pkgs,
  username,
  ...
}:
/*
  unzip is a command-line utility used to extract files from ZIP archives.
  It supports standard `.zip` files and allows listing, testing, and
  extracting their contents.

  It's useful for handling compressed archives.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.unzip
    ];
  };
}
