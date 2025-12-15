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
      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
        };
        "github.com" = {
          user = username;
          identityFile = "~/.ssh/${username}";
          identitiesOnly = true;
        };
        "sisyphe.sagbot.com" = {
          user = username;
          identityFile = "~/.ssh/${username}";
          identitiesOnly = true;
        };
        "icare.sagbot.com" = {
          user = username;
          identityFile = "~/.ssh/${username}";
          identitiesOnly = true;
        };
      };
    };
  };
}
