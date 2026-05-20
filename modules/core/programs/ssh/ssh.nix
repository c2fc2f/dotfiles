{ username, ... }:
/*
  SSH client configuration for the user, allowing customization of SSH
  settings such as known hosts, identities, and connection preferences.
  Useful for managing secure remote access to servers.
*/
{
  home-manager.users.${username} = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "Host *" = {
          addKeysToAgent = "yes";
        };
      };
    };
  };
}
