{
  lib,
  username,
  systemInfo,
  ...
}:
/*
  SSH client configuration for the user, allowing customization of SSH
  settings such as known hosts, identities, and connection preferences.
  Useful for managing secure remote access to servers.
*/
let
  serverHosts = lib.filter (
    name: lib.elem "server" systemInfo.${name}.groups && !(lib.elem "iso" systemInfo.${name}.groups)
  ) (lib.attrNames systemInfo);
in
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
      }
      // (builtins.listToAttrs (
        map (name: {
          inherit name;
          value = {
            hostname = "${name}.sagbot.com";
            user = username;
            identityFile = "~/.ssh/${username}";
            identitiesOnly = true;
          };
        }) serverHosts
      ));
    };
  };
}
