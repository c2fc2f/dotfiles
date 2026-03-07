{
  lib,
  username,
  systemInfo,
  mainDomain,
  ...
}:
let
  serverHosts = lib.filter (name: lib.elem "server" systemInfo.${name}.groups) (
    lib.attrNames systemInfo
  );
in
{
  home-manager.users.${username} = {
    programs.ssh.matchBlocks = {
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
          hostname = "${name}.${mainDomain}";
          user = username;
          identityFile = "~/.ssh/${username}";
          identitiesOnly = true;
        };
      }) serverHosts
    ));
  };
}
