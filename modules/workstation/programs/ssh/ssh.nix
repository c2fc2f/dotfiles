{
  lib,
  username,
  systemInfo,
  rootDomain,
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
      "Host *" = {
        ControlMaster = "auto";
        ControlPath = "/run/nix-ssh/%u-%r@%h:%p";
        ControlPersist = "10m";
      };

      "Host github" = {
        hostname = "github.com";
        user = username;
      };
    }
    // (builtins.listToAttrs (
      map (name: {
        name = "Host ${name}";
        value = {
          hostname = "${name}.${rootDomain}";
          user = username;
        };
      }) serverHosts
    ));
  };

  systemd.tmpfiles.rules = [ "d /run/nix-ssh 1777 root root -" ];
}
