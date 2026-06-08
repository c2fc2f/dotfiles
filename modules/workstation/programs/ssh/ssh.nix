{
  lib,
  username,
  systemInfo,
  mainDomain,
  ...
}:
let
  serverHosts = lib.filter (
    name: lib.elem "server" systemInfo.${name}.groups
  ) (lib.attrNames systemInfo);
in
{
  home-manager.users.${username} = {
    programs.ssh.settings = {
      "Host github" = {
        hostname = "github.com";
        user = username;
      };
    }
    // (builtins.listToAttrs (
      map (name: {
        name = "Host ${name}";
        value = {
          hostname = "${name}.${mainDomain}";
          user = username;
        };
      }) serverHosts
    ));
  };
}
