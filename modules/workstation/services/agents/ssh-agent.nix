{ username, ... }:
/*
  SSH agent service, which securely stores private SSH keys in memory and
  handles authentication, so you don't have to re-enter your passphrase each
  time you connect to a server.
*/
{
  home-manager.users.${username} = {
    services.ssh-agent = {
      enable = true;
    };
  };
}
