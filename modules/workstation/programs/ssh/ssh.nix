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
      "Host github" = {
        hostname = "github.com";
        user = username;
        ControlMaster = "auto";
        ControlPath = "/run/nix-ssh/%u-%r@%h:%p";
        ControlPersist = "10m";
      };
    }
    // (builtins.listToAttrs (
      map (name: {
        name = "Host ${name}";
        value = {
          hostname = "${name}.${rootDomain}";
          user = username;
          ControlMaster = "auto";
          ControlPath = "/run/nix-ssh/%u-%r@%h:%p";
          ControlPersist = "10m";
        };
      }) serverHosts
    ));
  };

  systemd.tmpfiles.rules = [ "d /run/nix-ssh 1777 root root -" ];
}
