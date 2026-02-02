{
  pkgs,
  username,
  ...
}:
/*
  fd is a simple, fast, and user-friendly alternative to the Unix `find`
  command. It offers intuitive syntax, colorized output, and smart defaults,
  making it easier and quicker to search for files and directories.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.fd
    ];
  };
}
