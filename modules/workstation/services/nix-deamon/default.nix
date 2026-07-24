{
  lib,
  config,
  username,
  ...
}:

{
  systemd.services.nix-daemon = {
    environment = {
      SSH_AUTH_SOCK = "/run/user/${
        builtins.toString config.users.users.${username}.uid
      }/${config.home-manager.users.${username}.services.ssh-agent.socket}";
      NIX_SSHOPTS = lib.replaceStrings [ "\n" ] [ " " ] ''
        -o ControlMaster=auto
        -o ControlPath=/run/nix-ssh/%%C
        -o ControlPersist=10m
      '';
    };
  };
}
