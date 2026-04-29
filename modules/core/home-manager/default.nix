{
  config,
  username,
  home-manager,
  ...
}:
/*
  Declares and configures Home Manager as a NixOS module.
   - Imports the Home Manager module into the system configuration.
   - Enables global access to Nixpkgs and user-level packages.
   - Sets a custom file extension for Home Manager backups.
   - Initializes Home Manager for the given user, setting their username
     and home directory, and enables `home-manager` itself for managing
     the user environment declaratively.
*/
{
  imports = [ home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";

    users.${username} = {
      programs.home-manager.enable = true;
      home = {
        inherit username;
        homeDirectory = config.users.users.${username}.home;
      };
    };
  };
}
