{
  pkgs,
  username,
  ...
}:
/*
  file is a command-line utility that determines the type of a given file. It
  inspects the contents rather than relying on file extensions, and outputs a
  human-readable description (e.g., text, binary, image format).
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.file
    ];
  };
}
