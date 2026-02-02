{
  config,
  username,
  ...
}:

{
  systemd.services.nix-daemon = {
    environment = {
      SSH_AUTH_SOCK = "/run/user/${builtins.toString config.users.users.${username}.uid}/${
        config.home-manager.users.${username}.services.ssh-agent.socket
      }";
    };
  };
}
