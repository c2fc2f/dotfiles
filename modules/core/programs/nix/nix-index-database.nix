{
  nix-index-database,
  username,
  ...
}:
/*
  Configures nix-index-database for the user by importing the appropriate Home
  Manager module. This setup provides an efficient way to search for files and
  commands in the Nix store.

    - The `imports` line includes the nix-index-database module, integrating
      it with Home Manager.
    - Enabling `programs.nix-index-database.comma` activates the `comma`
      command, which allows running commands from packages not yet installed
      by fetching them on demand.

  Useful for improving developer workflows by quickly locating and temporarily
  running tools.
*/
{
  home-manager.users.${username} = {
    imports = [
      nix-index-database.homeModules.nix-index
    ];

    programs.nix-index-database = {
      comma = {
        enable = true;
      };
    };
  };
}
