{
  username,
  ...
}:
/*
  nix-index, a command-line tool that indexes the entire Nix package set to
  allow fast file lookup. It enables users to find out which package provides
  a specific file or command using tools like `nix-locate`, making it easier
  to discover and install the right packages.
*/
{
  home-manager.users.${username} = {
    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
